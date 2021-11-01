//
//  DailyViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/27.
//

import Foundation
import GeometricWeatherBasic

private let topInset = 56.0

class DailyViewController: GeoViewController<(location: Location, initIndex: Int)>,
                            UIPageViewControllerDataSource,
                            UIPageViewControllerDelegate {
    
    // MARK: - subviews.
    
    private let blurBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .prominent)
    )
    private let titleContainer = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let indicatorLabel = UILabel(frame: .zero)
    private let divider = UIView(frame: .zero)
    
    private var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: .none
    )
    private var pageList = [DailyPageController]()
    
    // MARK: - data.
    
    private var currentIndex = 0
    private var nextIndex = 0
    
    // MARK: - life cycle.
    
    override init(param: (location: Location, initIndex: Int)) {
        super.init(param: param)
        
        guard let weather = self.param.location.weather else {
            return
        }
        
        for i in 0 ..< weather.dailyForecasts.count {
            self.pageList.append(
                DailyPageController(
                    weather: weather,
                    index: i,
                    timezone: self.param.location.timezone
                )
            )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.blurBackground)
        
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
        self.blurBackground.contentView.addSubview(self.pageViewController.view)
        
        self.updateTitle(self.param.initIndex)
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.titleContainer.addSubview(self.titleLabel)
        
        self.updateIndicator(self.param.initIndex)
        self.indicatorLabel.font = miniCaptionFont
        self.indicatorLabel.textColor = .label
        self.titleContainer.addSubview(self.indicatorLabel)
        
        self.titleContainer.backgroundColor = .systemBackground
        self.blurBackground.contentView.addSubview(self.titleContainer)
        
        self.divider.backgroundColor = .separator
        self.blurBackground.contentView.addSubview(self.divider)
        
        self.blurBackground.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.pageViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topInset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.titleContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(topInset)
        }
        self.indicatorLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(128.0)
        }
        self.divider.snp.makeConstraints { make in
            make.top.equalTo(self.titleContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - ui.
    
    private func updateTitle(_ index: Int) {
        self.titleLabel.text = self.param.location.weather?.dailyForecasts[
            index
        ].getDate(
            format: NSLocalizedString("date_format_widget_long", comment: "")
        ) ?? ""
    }
    
    private func updateIndicator(_ index: Int) {
        self.indicatorLabel.text = "\(index + 1)/\(self.param.location.weather?.dailyForecasts.count ?? 0)"
    }
    
    // MARK: - data source.
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let element = viewController as? DailyPageController else {
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
        guard let element = viewController as? DailyPageController else {
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
        guard let nextPage = pendingViewControllers.first as? DailyPageController else {
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
