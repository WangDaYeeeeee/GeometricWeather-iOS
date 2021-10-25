//
//  ViewController.swift
//  Demo
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit
import GeometricWeatherBasic

class MainViewController: UIViewController,
                            DragSwitchDelegate,
                            MainTimeBarDelegate,
                            UIScrollViewDelegate {
        
    // MARK: - view models.

    let viewModel = MainViewModel()
    
    // MARK: - inner data.
    
    // state values.
    
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
            let targetAlpha = blurNavigationBar ? 1.0 : 0.0
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
    lazy var managementViewController: ManagementViewController = {
        return ManagementViewController(self.viewModel)
    }()
    
    let dragSwitchView = DragSwitchView(frame: .zero)
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    let indicator = DotPagerIndicator(frame: .zero)
    
    let alertViewController = AlertViewController()
    
    // MARK: - life cycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "building.2.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(self.onManagementButtonClicked)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(self.onSettingsButtonClicked)
        )
        
        self.initSubviewsAndLayoutThem()
        
        // observe theme changed.
        
        ThemeManager.shared.homeOverrideUIStyle.observeValue(
            self
        ) { newValue in
            self.overrideUserInterfaceStyle = newValue
            self.updateNavigationBarTintColor()
            
            self.indicator.selectedColor = newValue == .light
            ? UIColor.black.cgColor
            : UIColor.white.cgColor
            self.indicator.unselectedColor = newValue == .light
            ? UIColor.black.withAlphaComponent(0.2).cgColor
            : UIColor.white.withAlphaComponent(0.2).cgColor
        }
        ThemeManager.shared.daylight.observeValue(
            self
        ) { _ in
            self.updatePreviewableSubviews()
        }
        
        // observe live data.
        
        self.viewModel.currentLocation.observeValue(
            self
        ) { newValue in
            self.updatePreviewableSubviews()
            self.updateTableView()
        }
        self.viewModel.loading.observeValue(
            self
        ) { newValue in
            self.updateTableViewRefreshControl(refreshing: newValue)
        }
        self.viewModel.indicator.observeValue(
            self
        ) { newValue in
            if self.indicator.selectedIndex != newValue.index {
                self.indicator.selectedIndex = newValue.index
            }
            if self.indicator.totalIndex != newValue.total {
                self.indicator.totalIndex = newValue.total
            }
            
            self.dragSwitchView.dragEnabled = newValue.total > 1
        }
        
        // register notification observers.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onBackgroundUpdate(_:)),
            name: .backgroundUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateTableView),
            name: .settingChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.responseAlertNotificationAction),
            name: .alertNotificationAction,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.responseForecastNotificationAction),
            name: .forecastNotificationAction,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.responseAppShortcutItemAction(_:)),
            name: .appShortcutItemAction,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewIsAppeared = true
        
        // start the indicator animation when this view enter to foreground if app is loading.
        self.updateTableViewRefreshControl(refreshing: self.viewModel.loading.value)
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        ThemeManager.shared.homeOverrideUIStyle.stopObserve(self)
        ThemeManager.shared.daylight.stopObserve(self)
        
        self.viewModel.currentLocation.stopObserve(self)
        self.viewModel.loading.stopObserve(self)
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
        self.updateTableViewRefreshControl(refreshing: self.viewModel.loading.value)
        self.viewModel.checkToUpdate()
    }
    
    @objc private func viewWillEnterBackground() {
        // stop the indicator animation when app enter to background.
        // otherwise we will find an error animation on indicator.
        self.updateTableViewRefreshControl(refreshing: false)
    }
    
    @objc private func onBackgroundUpdate(_ notification: NSNotification) {
        if let location = (notification.object as? Location) {
            self.viewModel.updateLocationFromBackground(location: location)
        }
    }
    
    // MARK: - UI.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    private func updatePreviewableSubviews() {
        let location = self.viewModel.getValidLocation(
            offset: self.previewOffset
        )
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
        
        let darkContent = blurNavigationBar && uiStyle == .light
        
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
        if self.navigationController?.presentedViewController != nil {
            return
        }
        self.navigationController?.present(
            self.managementViewController,
            animated: true,
            completion: nil
        )
    }
    
    @objc private func onSettingsButtonClicked() {
        self.navigationController?.pushViewController(
            SettingsViewController(),
            animated: true
        )
    }
    
    @objc func onPullRefresh() {
        self.viewModel.updateWithUpdatingChecking()
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
        if !self.viewModel.offsetLocation(offset: indexOffset) {
            updateTableView()
        }
        
        self.delayHidePageIndicator()
    }
    
    func onRebounded() {
        self.delayHidePageIndicator()
    }
    
    // main time bar.
    
    func reactManagementAction() {
        self.onManagementButtonClicked()
    }

    func reactAlertAction() {
        if self.navigationController?.presentedViewController != nil {
            return
        }
        self.alertViewController.alertList = self.viewModel.currentLocation.value.weather?.alerts ?? []
        self.navigationController?.present(
            alertViewController,
            animated: true,
            completion: nil
        )
    }
    
    // scroll.
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.showPageIndicator()
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        self.delayHidePageIndicator()
    }
}
