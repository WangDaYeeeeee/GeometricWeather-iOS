//
//  AlertViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import UIKit

private let cellReuseId = "AlertTableViewCell"

private let topInset = 56.0

class AlertViewController: GeoViewController,
                            UITableViewDataSource,
                            UITableViewDelegate {
    
    // MARK: - properties.
    
    // subviews.
    
    private let blurBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .prominent)
    )
    private let titleContainer = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let divider = UIView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // data & controllers.
    
    var alertList = [Alert]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.blurBackground)
        
        self.tableView.backgroundColor = .clear
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .opaqueSeparator.withAlphaComponent(0.5)
        self.tableView.separatorInset = .zero
        self.tableView.register(
            AlertTableViewCell.self,
            forCellReuseIdentifier: cellReuseId
        )
        self.blurBackground.contentView.addSubview(self.tableView)
        
        self.titleLabel.text = NSLocalizedString("action_alert", comment: "")
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.titleContainer.addSubview(self.titleLabel)
        
        self.titleContainer.backgroundColor = .systemBackground
        self.blurBackground.contentView.addSubview(self.titleContainer)
        
        self.divider.backgroundColor = .separator
        self.blurBackground.contentView.addSubview(self.divider)
        
        self.blurBackground.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
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
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.divider.snp.makeConstraints { make in
            make.top.equalTo(self.titleContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - delegates.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.alertList.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseId,
            for: indexPath
        )
        (cell as? AlertTableViewCell)?.bindData(
            self.alertList[indexPath.row]
        )
        return cell
    }
}
