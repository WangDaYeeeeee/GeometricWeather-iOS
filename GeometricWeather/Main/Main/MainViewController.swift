//
//  ViewController.swift
//  Demo
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit

class MainViewController: UIViewController,
                            DragSwitchDelegate,
                            MainTimeBarDelegate {
    
    // MARK: - properties.
    
    // vm.
    
    lazy var viewModel: MainViewModel = {
        let vm = MainViewModel()
        vm.toastParentProvider = { [weak self] in
            if let presented = self?.navigationController?.presentedViewController {
                return presented.view
            }
            return self?.view
        }
        return vm
    }()
    
    // inner data.
    
    private var previewOffset = 0 {
        didSet {
            DispatchQueue.main.async {
                self.updatePreviewableSubviews()
            }
        }
    }
    private var statusBarStyle = UIStatusBarStyle.lightContent {
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
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                self?.navigationBarBackground.alpha = targetAlpha
            }, completion: nil)
        }
    }
    var cellKeyList = [String]()
    var headerCache = MainTableViewHeaderView(frame: .zero)
    var cellCache = Dictionary<String, MainTableViewCell>()
    var cellHeightCache = Dictionary<String, CGFloat>()
    var cellAnimationHelper = StaggeredCellAnimationHelper()
    
    // subviews.
    
    private let weatherViewController = WeatherViewController()
    private lazy var managementViewController: ManagementViewController = {
        return ManagementViewController(self.viewModel)
    }()
    
    private let dragSwitchView = DragSwitchView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    private let indicator = DotPagerIndicator(frame: .zero)
    
    private let alertViewController = AlertViewController()
    
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
        
        self.weatherViewController.view.backgroundColor = .clear
        self.addChild(self.weatherViewController)
        self.view.addSubview(self.weatherViewController.view)
        
        self.dragSwitchView.delegate = self
        self.view.addSubview(self.dragSwitchView)
        
        self.cellCache = self.prepareCellCache()
        self.tableView.backgroundColor = .clear
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .white
        self.tableView.refreshControl?.addTarget(
            self,
            action: #selector(self.onPullRefresh),
            for: .valueChanged
        )
        self.dragSwitchView.contentView.addSubview(self.tableView)
        
        self.navigationBarBackground.alpha = 0
        self.view.addSubview(self.navigationBarBackground)
        
        self.view.addSubview(self.indicator)
        
        self.weatherViewController.view.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.dragSwitchView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.navigationBarBackground.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
        }
        self.indicator.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(littleMargin * 3)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // register notification observers.
        
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
        
        // observe theme changed.
        
        ThemeManager.shared.homeOverrideUIStyle.observeValue(
            self.description
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
            self.description
        ) { _ in
            self.updatePreviewableSubviews()
        }
        
        // observe live data.
        
        self.viewModel.currentLocation.observeValue(
            self.description
        ) { newValue in
            self.updatePreviewableSubviews()
            self.updateTableView()
        }
        self.viewModel.loading.observeValue(
            self.description
        ) { newValue in
            if let refreshControl = self.tableView.refreshControl {
                
                if newValue && !refreshControl.isRefreshing {
                    refreshControl.beginRefreshing()
                } else if !newValue && refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
        self.viewModel.indicator.observeValue(
            self.description
        ) { newValue in
            if self.indicator.selectedIndex != newValue.index {
                self.indicator.selectedIndex = newValue.index
            }
            if self.indicator.totalIndex != newValue.total {
                self.indicator.totalIndex = newValue.total
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updatePreviewableSubviews()
        self.updateNavigationBarTintColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("action_home", comment: "")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        ThemeManager.shared.homeOverrideUIStyle.stopObserve(self.description)
        ThemeManager.shared.daylight.stopObserve(self.description)
        
        self.viewModel.currentLocation.stopObserve(self.description)
        self.viewModel.loading.stopObserve(self.description)
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cellHeightCache.removeAll()
    }
    
    @objc private func viewWillEnterForeground() {
        self.viewModel.checkToUpdate()
    }
    
    @objc private func viewWillEnterBackground() {
        self.viewModel.cancelRequest()
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
        
        self.navigationItem.title = getLocationText(location: location)
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
        
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
    }
    
    @objc private func updateTableView() {
        if self.tableView.numberOfSections != 0
            && self.tableView.numberOfRows(inSection: 0) != 0 {
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
        self.tableView(
            self.tableView,
            didEndDisplayingHeaderView: self.headerCache,
            forSection: 0
        )
        
        self.cellKeyList = self.prepareCellKeyList(
            location: self.viewModel.currentLocation.value
        )
        self.cellAnimationHelper.reset()
        self.tableView.reloadData()
        self.bindDataForHeaderAndCells(self.viewModel.currentLocation.value)
        
        self.tableView(
            self.tableView,
            willDisplayHeaderView: self.headerCache,
            forSection: 0
        )
    }
    
    // MARK: - actions.
    
    @objc private func onManagementButtonClicked() {
        if self.managementViewController.view.superview != nil {
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
    
    @objc private func onPullRefresh() {
        self.viewModel.updateWithUpdatingChecking()
    }
    
    // MARK: - delegates.
    
    // drag switch.
    
    func onSwiped(_ progress: Double) {
        if self.previewOffset != 0 && fabs(progress) <= 1 {
            // cancel preview.
            self.previewOffset = 0
        } else if self.previewOffset == 0 && fabs(progress) > 1 {
            // start preview.
            self.previewOffset = progress > 0 ? 1 : -1
        }
    }
    
    func onSwitched(_ indexOffset: Int) {
        self.previewOffset = 0
        
        if !self.viewModel.offsetLocation(offset: indexOffset) {
            updateTableView()
        }
    }
    
    // main time bar.
    
    func reactManagementAction() {
        self.onManagementButtonClicked()
    }

    func reactAlertAction() {
        if self.alertViewController.view.superview != nil {
            return
        }
        self.alertViewController.alertList = self.viewModel.currentLocation.value.weather?.alerts ?? []
        self.navigationController?.present(
            alertViewController,
            animated: true,
            completion: nil
        )
    }
}
