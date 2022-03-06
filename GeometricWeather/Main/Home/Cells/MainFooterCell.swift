//
//  MainFooterCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/28.
//

import Foundation
import GeometricWeatherBasic

struct MainFooterEditButtonTapAction {}

class MainFooterCell: UITableViewCell, AbstractMainItem {
    
    private let titleLabel = UILabel(frame: .zero)
    private let editButton = CornerButton(frame: .zero, useLittleMargin: true)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.titleLabel.font = .systemFont(
            ofSize: captionFont.pointSize,
            weight: .bold
        )
        self.titleLabel.textColor = .white
        self.contentView.addSubview(self.titleLabel)
        
        self.editButton.titleLabel?.font = miniCaptionFont
        self.editButton.setTitleColor(.white, for: .normal)
        self.editButton.backgroundColor = .white.withAlphaComponent(0.33)
        self.editButton.addTarget(
            self,
            action: #selector(self.onEditTapped),
            for: .touchUpInside
        )
        self.contentView.addSubview(self.editButton)

        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        self.editButton.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(littleMargin)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location, timeBar: MainTimeBarView?) {
        self.titleLabel.text = "Powered by " + SettingsManager.shared.weatherSource.url
        self.editButton.setTitle(
            NSLocalizedString("edit", comment: ""),
            for: .normal
        )
    }
    
    @objc private func onEditTapped() {
        EventBus.shared.post(
            MainFooterEditButtonTapAction()
        )
    }
}
