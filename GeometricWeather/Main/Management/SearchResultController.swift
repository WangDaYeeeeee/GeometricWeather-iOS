//
//  SearchViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/28.
//

import UIKit
import GeometricWeatherBasic

private let cellReuseId = "SearchTableViewCell"

class SearchResultController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate {
    
    // MARK: - properties.
    
    // controllers.
    
    private let weatherApi = getWeatherApi(SettingsManager.shared.weatherSource)
    private var cancelToken: CancelToken?
        
    // inner data.
    
    private var locationList = [Location]()
    var locationCount: Int {
        get {
            return self.locationList.count
        }
    }
    
    let requesting = EqualtableLiveData(false)
    
    // subviews.
    
    private let tableView = AutoHideKeyboardTableView(frame: .zero, style: .plain)
    private let progressView = UIActivityIndicatorView(style: .large)
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.backgroundColor = .clear
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .opaqueSeparator.withAlphaComponent(0.5)
        self.tableView.separatorInset = .zero
        self.tableView.rowHeight = locationCellHeight
        self.tableView.register(
            SearchTableViewCell.self,
            forCellReuseIdentifier: cellReuseId
        )
        self.tableView.hideKeyboardExecutor = {
            EventBus.shared.post(HideKeyboardEvent())
        }
        self.view.addSubview(self.tableView)
        
        self.progressView.color = .label
        self.progressView.startAnimating()
        self.progressView.layoutMargins = .zero
        self.view.addSubview(self.progressView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.requesting.addObserver(self) { newValue in
            if newValue {
                UIView.animate(withDuration: 0.3) {
                    self.tableView.alpha = 0.0
                    self.progressView.alpha = 1.0
                }
            } else {
                self.cancelRequest()
                
                UIView.animate(withDuration: 0.3) {
                    self.tableView.alpha = 1.0
                    self.progressView.alpha = 0.0
                }
            }
        }
    }
    
    // MARK: - interfaces.
    
    func search(_ text: String) {
        self.cancelRequest()
        self.requesting.value = true
        
        self.cancelToken = self.weatherApi.getLocation(
            text
        ) { [weak self] locations in
            if locations.isEmpty {
                ToastHelper.showToastMessage(
                    NSLocalizedString("feedback_search_nothing", comment: "")
                )
            }
            
            self?.requesting.value = false
            
            self?.locationList = locations
            self?.tableView.reloadData()
        }
    }
    
    private func cancelRequest() {
        self.cancelToken?.cancelRequest()
        self.cancelToken = nil
    }
    
    func resetList() {
        self.locationList = []
        self.tableView.reloadData()
    }
    
    // MARK: - delegates.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.locationList.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseId,
            for: indexPath
        )
        (cell as? SearchTableViewCell)?.bindData(
            location: self.locationList[indexPath.row],
            selected: false
        )
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        EventBus.shared.post(AddLocationEvent(
            location: self.locationList[indexPath.row])
        )
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        EventBus.shared.post(HideKeyboardEvent())
    }
}
