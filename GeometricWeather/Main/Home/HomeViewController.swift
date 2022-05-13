//
//  HomeViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit
import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class HomeViewController: UIViewController,
                            DragSwitchDelegate,
                            UIScrollViewDelegate {
        
    // MARK: - view models.

    let vm: MainViewModel
    
    // MARK: - router.
    
    let editBuilder: EditBuilder
    let settingsBuilder: SettingsBuilder
    
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
            self.navigationBarBackgroundShadow.layer.removeAllAnimations()
            
            let targetAlpha = self.blurNavigationBar ? 1.0 : 0.0
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut]
            ) { [weak self] in
                self?.navigationBarBackground.alpha = targetAlpha
                self?.navigationBarBackgroundShadow.alpha = targetAlpha
            } completion: { _ in
                // do nothing.
            }
        }
    }
        
    // cells.
    
    var cellKeyList = [String]()
    var headerCache = MainTableViewHeaderView(frame: .zero)
    var timeBarCache = MainTimeBarView(frame: .zero)
    var cellCache = Dictionary<String, AbstractMainItem>()
    var cellHeightCache = Dictionary<String, CGFloat>()
    var cellAnimationHelper = StaggeredCellAnimationHelper()
    
    // timers.
    
    var hideIndicatorTimer: Timer?
    
    // reactor.
    
    let dragSwitchImpactor = UIImpactFeedbackGenerator(style: .rigid)
    
    // MARK: - subviews.
    
    lazy var weatherViewController: WeatherViewController<MaterialWeatherView> = {
        let state = WeatherViewState(
            weatherKind: .null,
            daylight: isDaylight()
        )
        return WeatherViewController(
            ThemeManager.weatherThemeDelegate.getWeatherView(state: state),
            state: state
        )
    }()
    
    let dragSwitchView = DragSwitchView(frame: .zero)
    let tableView = AutoHideKeyboardTableView(frame: .zero, style: .grouped)
    
    let navigationBarTitleView = MainNavigationBarTitleView(frame: .zero)
    let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    let navigationBarBackgroundShadow = UIView(frame: .zero)
    
    let indicator = DotPagerIndicator(frame: .zero)
        
    // MARK: - life cycle.
    
    init(
        vm: MainViewModel,
        splitView: Bool,
        editBuilder: EditBuilder,
        settingsBuilder: SettingsBuilder
    ) {
        self.vm = vm
        self.splitView = splitView
        self.editBuilder = editBuilder
        self.settingsBuilder = settingsBuilder
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviewsAndLayoutThem()
        
        // observe theme changed.
                
        self.navigationController?.view.window?.windowScene?.themeManager.homeOverrideUIStyle.addObserver(
            self
        ) { [weak self] newValue in
            self?.overrideUserInterfaceStyle = newValue
            self?.updateNavigationBarTintColor()
            
            self?.indicator.selectedColor = newValue == .light
            ? UIColor.black.cgColor
            : UIColor.white.cgColor
            self?.indicator.unselectedColor = newValue == .light
            ? UIColor.black.withAlphaComponent(0.2).cgColor
            : UIColor.white.withAlphaComponent(0.2).cgColor
        }
        self.navigationController?.view.window?.windowScene?.themeManager.daylight.addObserver(
            self
        ) { [weak self] _ in
            self?.updatePreviewableSubviews()
        }
        
        // observe live data.
        
        self.vm.currentLocation.addObserver(self) { [weak self] newValue in
            self?.updatePreviewableSubviews()
            self?.updateTableView()
        }
        self.vm.loading.addObserver(self) { [weak self] newValue in
            if newValue == self?.tableView.refreshControl?.isRefreshing {
                return
            }
            if newValue {
                self?.tableView.refreshControl?.beginRefreshingWithOffset()
            } else {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
        self.vm.indicator.addObserver(self) { [weak self] newValue in
            if self?.indicator.selectedIndex != newValue.index {
                self?.indicator.selectedIndex = newValue.index
            }
            if self?.indicator.totalIndex != newValue.total {
                self?.indicator.totalIndex = newValue.total
            }
            
            self?.dragSwitchView.dragEnabled = newValue.total > 1
        }
        
        self.vm.toastMessage.addObserver(self) { [weak self] newValue in
            if let message = newValue {
                self?.showToastMessage(message)
            }
        }
        
        // observe app enter foreground.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // register event observers.
        
        self.registerEventObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updatePreviewableSubviews()
        self.updateNavigationBarTintColor()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async {
            self.rotateHeaderAndCells()
        }
    }
    
    @objc private func viewWillEnterForeground() {
        self.vm.checkToUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let titleView = self.navigationItem.titleView {
            self.navigationItem.titleView = nil
            self.navigationItem.titleView = titleView
        }
    }
    
    // MARK: - UI.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    private func updatePreviewableSubviews() {
        let location = self.vm.getValidLocation(
            offset: self.previewOffset
        )
        
        let daylight = isDaylight(location: location)
        
        self.navigationBarTitleView.title = getLocationText(location: location)
        self.navigationBarTitleView.showCurrentPositionIcon = location.currentPosition
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
        self.navigationBarTitleView.tintColor = color
    }
    
    // MARK: - toast.
    
    func showToastMessage(_ message: MainToastMessage) {
        switch message {
        case .backgroundUpdate:
            ToastHelper.showToastMessage(
                getLocalizedText("feedback_updated_in_background"),
                inWindowOfView: self.view
            )
            return
            
        case .locationFailed:
            ToastHelper.showToastMessage(
                getLocalizedText("feedback_location_failed"),
                inWindowOfView: self.view
            )
            return
            
        case .weatherRequestFailed:
            ToastHelper.showToastMessage(
                getLocalizedText("feedback_get_weather_failed"),
                inWindowOfView: self.view
            )
            return
        }
    }
    
    // MARK: - actions.
    
    @objc func onManagementButtonClicked() {
        self.navigationController?.view.window?.windowScene?.eventBus.post(
            TimeBarManagementAction()
        )
    }
    
    @objc func onSettingsButtonClicked() {
        self.navigationController?.pushViewController(
            self.settingsBuilder.settingsViewController,
            animated: true
        )
    }
    
    @objc func onPullRefresh() {
        self.vm.updateCurrentLocationWithChecking()

        if let refreshControl = self.tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - delegates.
    
    // drag switch.
    
    func onSwiped(_ progress: Double, isDragging: Bool) {
        if self.previewOffset != 0 && fabs(progress) <= 1 {
            // cancel preview.
            self.dragSwitchImpactor.impactOccurred()
            
            self.previewOffset = 0
        } else if self.previewOffset == 0 && fabs(progress) > 1 {
            // start preview.
            self.dragSwitchImpactor.impactOccurred()
            
            self.previewOffset = progress > 0 ? 1 : -1
        }
        
        if isDragging {
            self.showPageIndicator()
        }
    }
    
    func onSwitched(_ indexOffset: Int) {
        self.previewOffset = 0
        
        self.hideHeaderAndCells()
        if !self.vm.offsetLocation(
            offset: indexOffset
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
        self.view.window?.windowScene?.eventBus.post(HideKeyboardEvent())
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        self.delayHidePageIndicator()
    }
}
