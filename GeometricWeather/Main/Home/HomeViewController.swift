//
//  HomeViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit
import GeometricWeatherBasic

class HomeViewController: UIViewController,
                            DragSwitchDelegate,
                            UIScrollViewDelegate {
        
    // MARK: - view models.

    let vmWeakRef: MainViewModelWeakRef
    
    // MARK: - inner data.
    
    // state values.
    
    let splitView: Bool
    
    var previewOffset = 0 {
        didSet {
            DispatchQueue.main.async {
                self.updatePreviewableSubviews()
            }
        }
    }
    var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var blurNavigationBar = false {
        didSet {
            self.updateNavigationBarTintColor()
            
            self.navigationBarBackground.layer.removeAllAnimations()
            let targetAlpha = self.blurNavigationBar ? 1.0 : 0.0
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut]
            ) { [weak self] in
                self?.navigationBarBackground.alpha = targetAlpha
            } completion: { _ in
                // do nothing.
            }
        }
    }
    
    var viewIsAppeared = false
    
    // cells.
    
    var cellKeyList = [String]()
    var headerCache = MainTableViewHeaderView(frame: .zero)
    var cellCache = Dictionary<String, MainTableViewCell>()
    var cellHeightCache = Dictionary<String, CGFloat>()
    var cellAnimationHelper = StaggeredCellAnimationHelper()
    
    // timers.
    
    var hideIndicatorTimer: Timer?
    
    // MARK: - subviews.
    
    let weatherViewController = ThemeManager.shared.weatherThemeDelegate.getWeatherViewController()
    
    let dragSwitchView = DragSwitchView(frame: .zero)
    let tableView = AutoHideKeyboardTableView(frame: .zero, style: .grouped)
    
    let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    let indicator = DotPagerIndicator(frame: .zero)
        
    // MARK: - life cycle.
    
    init(vmWeakRef: MainViewModelWeakRef, splitView: Bool) {
        self.vmWeakRef = vmWeakRef
        self.splitView = splitView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        if !splitView {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "building.2.crop.circle"),
                style: .plain,
                target: self,
                action: #selector(self.onManagementButtonClicked)
            )
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(self.onSettingsButtonClicked)
        )
        
        self.initSubviewsAndLayoutThem()
        
        // observe theme changed.
        
        ThemeManager.shared.homeOverrideUIStyle.addObserver(self) { newValue in
            self.overrideUserInterfaceStyle = newValue
            self.updateNavigationBarTintColor()
            
            self.indicator.selectedColor = newValue == .light
            ? UIColor.black.cgColor
            : UIColor.white.cgColor
            self.indicator.unselectedColor = newValue == .light
            ? UIColor.black.withAlphaComponent(0.2).cgColor
            : UIColor.white.withAlphaComponent(0.2).cgColor
        }
        ThemeManager.shared.daylight.addObserver(self) { _ in
            self.updatePreviewableSubviews()
        }
        
        // observe live data.
        
        self.vmWeakRef.vm?.currentLocation.addObserver(self) { [weak self] newValue in
            self?.updatePreviewableSubviews()
            self?.updateTableView()
        }
        self.vmWeakRef.vm?.loading.addObserver(self) { [weak self] newValue in
            self?.updateTableViewRefreshControl(refreshing: newValue)
        }
        self.vmWeakRef.vm?.indicator.addObserver(self) { [weak self] newValue in
            if self?.indicator.selectedIndex != newValue.index {
                self?.indicator.selectedIndex = newValue.index
            }
            if self?.indicator.totalIndex != newValue.total {
                self?.indicator.totalIndex = newValue.total
            }
            
            self?.dragSwitchView.dragEnabled = newValue.total > 1
        }
        
        self.vmWeakRef.vm?.toastMessage.addObserver(self) { [weak self] newValue in
            if let message = newValue {
                self?.responseToastMessage(message)
            }
        }
        
        // register event observers.
        
        EventBus.shared.register(
            self,
            for: BackgroundUpdateEvent.self
        ) { [weak self] event in
            self?.vmWeakRef.vm?.updateLocationFromBackground(
                location: event.location
            )
        }
        EventBus.shared.register(
            self,
            for: SettingsChangedEvent.self
        ) { [weak self] _ in
            self?.updateTableView()
        }
        EventBus.shared.register(
            self,
            for: DailyTrendCellTapAction.self
        ) { [weak self] event in
            self?.responseDailyTrendCellTapAction(event.index)
        }
        EventBus.shared.register(self, for: TimeBarManagementAction.self) { [weak self] _ in
            if self?.splitView ?? false {
                return
            }
            
            self?.onManagementButtonClicked()
        }
        EventBus.shared.register(self, for: TimeBarAlertAction.self) { [weak self] _ in
            if self?.navigationController?.presentedViewController != nil {
                return
            }
            self?.navigationController?.present(
                AlertViewController(
                    param: self?.vmWeakRef.vm?.currentLocation.value.weather?.alerts ?? []
                ),
                animated: true,
                completion: nil
            )
        }
        EventBus.shared.stickyRegister(
            self,
            for: AlertNotificationAction.self
        ) { [weak self] event in
            if let _ = event {
                self?.responseAlertNotificationAction()
            }
        }
        EventBus.shared.stickyRegister(
            self,
            for: ForecastNotificationAction.self
        ) { [weak self] event in
            if let _ = event {
                self?.responseForecastNotificationAction()
            }
        }
        EventBus.shared.stickyRegister(
            self,
            for: AppShortcutItemAction.self
        ) { [weak self] event in
            if let id = event?.formattedId {
                self?.responseAppShortcutItemAction(id)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewIsAppeared = true
        
        // start the indicator animation when this view enter to foreground if app is loading.
        if let loading = self.vmWeakRef.vm?.loading.value {
            self.updateTableViewRefreshControl(refreshing: loading)
        }
        
        self.updatePreviewableSubviews()
        self.updateNavigationBarTintColor()
        
        // register app enter and exit foreground listener.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewWillEnterBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewIsAppeared = false
        
        // stop the indicator animation when this view enter to background.
        // otherwise we will find an error animation on indicator.
        self.updateTableViewRefreshControl(refreshing: false)
        
        self.navigationItem.title = NSLocalizedString("action_home", comment: "")
        
        // remove enter and exit foreground listener.
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cellHeightCache.removeAll()
    }
    
    @objc private func viewWillEnterForeground() {
        // start the indicator animation when app enter to foreground if app is loading.
        if let loading = self.vmWeakRef.vm?.loading.value {
            self.updateTableViewRefreshControl(refreshing: loading)
        }
        self.vmWeakRef.vm?.checkToUpdate()
    }
    
    @objc private func viewWillEnterBackground() {
        // stop the indicator animation when app enter to background.
        // otherwise we will find an error animation on indicator.
        self.updateTableViewRefreshControl(refreshing: false)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        self.vmWeakRef.vm?.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        self.vmWeakRef.vm?.decodeRestorableState(with: coder)
    }
    
    // MARK: - UI.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    private func updatePreviewableSubviews() {
        guard let location = self.vmWeakRef.vm?.getValidLocation(
            offset: self.previewOffset
        ) else {
            return
        }
        
        let daylight = self.previewOffset == 0
        ? ThemeManager.shared.daylight.value
        : isDaylight(location: location)
        
        if self.viewIsAppeared {
            self.navigationItem.title = getLocationText(location: location)
        }
        self.weatherViewController.update(
            weatherKind: weatherCodeToWeatherKind(
                code: location.weather?.current.weatherCode ?? .clear
            ),
            daylight: daylight
        )
    }
    
    private func updateNavigationBarTintColor() {
        var uiStyle = self.overrideUserInterfaceStyle
        if uiStyle == .unspecified {
            uiStyle = self.view.traitCollection.userInterfaceStyle
        }
        
        let darkContent = self.blurNavigationBar && uiStyle == .light
        
        self.statusBarStyle = darkContent ? .darkContent : .lightContent
        let color: UIColor = darkContent ? .black : .white
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func updateTableViewRefreshControl(refreshing: Bool) {
        if let refreshControl = self.tableView.refreshControl {
            if refreshing && !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            } else if !refreshing && refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - actions.
    
    @objc private func onManagementButtonClicked() {
        self.navigationController?.pushViewController(
            ManagementViewController(
                param: (
                    MainViewModelWeakRef(vm: self.vmWeakRef.vm),
                    false
                )
            ),
            animated: true
        )
    }
    
    @objc private func onSettingsButtonClicked() {
        self.navigationController?.pushViewController(
            SettingsViewController(param: ()),
            animated: true
        )
    }
    
    @objc func onPullRefresh() {
        self.vmWeakRef.vm?.updateWithUpdatingChecking()
    }
    
    // MARK: - delegates.
    
    // drag switch.
    
    func onSwiped(_ progress: Double, isDragging: Bool) {
        if self.previewOffset != 0 && fabs(progress) <= 1 {
            // cancel preview.
            self.previewOffset = 0
        } else if self.previewOffset == 0 && fabs(progress) > 1 {
            // start preview.
            self.previewOffset = progress > 0 ? 1 : -1
        }
        
        if isDragging {
            self.showPageIndicator()
        }
    }
    
    func onSwitched(_ indexOffset: Int) {
        self.previewOffset = 0
        
        self.hideHeaderAndCells()
        if !(
            self.vmWeakRef.vm?.offsetLocation(
                offset: indexOffset
            ) ?? false
        ) {
            self.updateTableView()
        }
        
        self.delayHidePageIndicator()
    }
    
    func onRebounded() {
        self.delayHidePageIndicator()
    }
    
    // scroll.
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.showPageIndicator()
        EventBus.shared.post(HideKeyboardEvent())
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        self.delayHidePageIndicator()
    }
}
