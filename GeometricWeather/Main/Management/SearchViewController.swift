//
//  SearchViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/28.
//

import UIKit
import GeometricWeatherBasic

private let observerKey = "SearchViewController"

private let cellReuseId = "SearchTableViewCell"

protocol SearchViewDelegate: NSObjectProtocol {
    
    // return true if we can collect this location to location list.
    func selectLocation(
        _ location: Location
    ) -> Bool
    func hideKeyboard(withEmptyList: Bool)
}

class SearchViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate {
    
    // MARK: - properties.
    
    // controllers.
    
    private let weatherApi = getWeatherApi(SettingsManager.shared.weatherSource)
    private var cancelToken: CancelToken?
    
    private weak var delegate: SearchViewDelegate?
    
    // inner data.
    
    private var locationList = [Location]()
    
    let requesting = EqualtableLiveData(false)
    
    // subviews.
    
    private let tableView = AutoHideKeyboardTableView(frame: .zero, style: .plain)
    private let progressView = UIActivityIndicatorView(style: .large)
    
    // MARK: - life cycle.
    
    init(delegate: SearchViewDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            LocationTableViewCell.self,
            forCellReuseIdentifier: cellReuseId
        )
        self.tableView.hideKeyboardExecutor = { [weak self] in
            self?.delegate?.hideKeyboard(
                withEmptyList: self?.locationList.isEmpty ?? true
            )
        }
        self.view.addSubview(self.tableView)
        
        self.progressView.color = .label
        self.progressView.startAnimating()
        self.view.addSubview(self.progressView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.requesting.observeValue(observerKey) { newValue in
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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.requesting.stopObserve(observerKey)
    }
    
    // MARK: - interfaces.
    
    func search(_ text: String) {
        self.cancelRequest()
        self.requesting.value = true
        
        self.cancelToken = self.weatherApi.getLocation(
            text
        ) { [weak self] locations in
            if locations.isEmpty {
                self?.navigationController?.view.showToastMessage(
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
        (cell as? LocationTableViewCell)?.bindData(
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
        
        if let delegate = self.delegate {
            if delegate.selectLocation(self.locationList[indexPath.row]) {
                self.navigationController?.view.showToastMessage(
                    NSLocalizedString("feedback_collect_succeed", comment: "")
                )
            } else {
                self.navigationController?.view.showToastMessage(
                    NSLocalizedString("feedback_collect_failed", comment: "")
                )
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.hideKeyboard(
            withEmptyList: self.locationList.isEmpty
        )
    }
}
