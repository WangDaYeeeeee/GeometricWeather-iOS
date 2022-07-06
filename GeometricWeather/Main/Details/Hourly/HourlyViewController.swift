//
//  HourlyViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/6/16.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import SwiftUI

private let topInset = 56.0

class HourlyViewController: GeoViewController<(location: Location, initIndex: Int)>,
                            UIPageViewControllerDataSource,
                            UIPageViewControllerDelegate {
    
    // MARK: - subviews.
    
    let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    let navigationBarBackgroundShadow = UIView(frame: .zero)
    
    private var pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: .none
        )
    private var pageList = [UIHostingController<HourlyView>]()
    
    // MARK: - data.
        
    private var currentIndex = 0
    private var nextIndex = 0
    
    override var preferLargeTitle: Bool {
        return false
    }
    
    // MARK: - life cycle.
    
    override init(param: (location: Location, initIndex: Int), in scene: UIWindowScene?) {
        super.init(param: param, in: scene)
        
        guard let weather = self.param.location.weather else {
            return
        }
        
        for i in 0 ..< weather.hourlyForecasts.count {
            let vc = UIHostingController<HourlyView>(
                rootView: HourlyView(
                    weather: weather,
                    index: i,
                    timezone: self.param.location.timezone
                )
            )
            self.pageList.append(vc)
            self.addChild(vc)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.updateTitle(self.param.initIndex)
        self.updateIndicator(self.param.initIndex)
                
        self.pageViewController.setViewControllers(
            [self.pageList[self.param.initIndex]],
            direction: .forward,
            animated: true,
            completion: nil
        )
        self.pageViewController.view.backgroundColor = .clear
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.view.addSubview(self.navigationBarBackground)
        
        self.navigationBarBackgroundShadow.backgroundColor = .opaqueSeparator
        self.view.addSubview(self.navigationBarBackgroundShadow)
        
        self.self.pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.navigationBarBackground.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
        }
        self.navigationBarBackgroundShadow.snp.makeConstraints { make in
            make.top.equalTo(self.navigationBarBackground.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scene?.themeManager.globalOverrideUIStyle.syncAddObserver(
            self
        ) { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.overrideUserInterfaceStyle = newValue
            
            if !strongSelf.isBeingPresented {
                let titleColor = strongSelf.view.traitCollection.userInterfaceStyle == .light
                ? UIColor.black
                : UIColor.white
                
                strongSelf.navigationController?.navigationBar.isTranslucent = true
                strongSelf.navigationController?.navigationBar.tintColor = .systemBlue
                strongSelf.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: titleColor
                ]
                strongSelf.navigationController?.navigationBar.setBackgroundImage(
                    UIImage(),
                    for: .default
                )
                strongSelf.navigationController?.navigationBar.shadowImage = UIImage()
                
                strongSelf.statusBarStyle = strongSelf.view.traitCollection.userInterfaceStyle == .light
                ? .darkContent
                : .lightContent
            }
        }
    }
    
    // MARK: - ui.
    
    private func updateTitle(_ index: Int) {
        self.navigationItem.title = formatTime(
            timeIntervalSine1970: self.param.location.weather?.hourlyForecasts.get(index)?.time ?? 0.0,
            twelveHour: isTwelveHour()
        )
    }
    
    private func updateIndicator(_ index: Int) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "\(index + 1)/\(self.param.location.weather?.hourlyForecasts.count ?? 0)",
            style: .plain,
            target: nil,
            action: nil
        )
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: miniCaptionFont,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ],for: .disabled)
    }
    
    // MARK: - data source.
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let element = viewController as? UIHostingController<HourlyView> else {
            return nil
        }
        guard let index = self.pageList.firstIndex(of: element) else {
            return nil
        }
        return self.pageList.get(index - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let element = viewController as? UIHostingController<HourlyView> else {
            return nil
        }
        guard let index = self.pageList.firstIndex(of: element) else {
            return nil
        }
        return self.pageList.get(index + 1)
    }
    
    // MARK: - delegate.
        
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        guard let nextPage = pendingViewControllers.first as? UIHostingController<HourlyView> else {
            return
        }
        guard let index = self.pageList.firstIndex(of: nextPage) else {
            return
        }
        self.nextIndex = index
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if !completed {
            return
        }
        
        self.currentIndex = self.nextIndex
        self.updateTitle(self.currentIndex)
        self.updateIndicator(self.currentIndex)
    }
}
