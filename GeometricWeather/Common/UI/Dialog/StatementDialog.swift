//
//  StatementDialog.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/18.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class StatementDialog: GeoDialog {
    
    init(title: String, content: String) {
        let container = UIView(frame: .zero)
        
        let vstack = UIStackView(frame: .zero)
        vstack.alignment = .center
        vstack.axis = .vertical
        vstack.spacing = normalMargin
        container.addSubview(vstack)
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = largeTitleFont
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        vstack.addArrangedSubview(titleLabel)
        
        let contentLabel = UILabel(frame: .zero)
        contentLabel.text = content
        contentLabel.textColor = .secondaryLabel
        contentLabel.font = bodyFont
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        vstack.addArrangedSubview(contentLabel)
        
        vstack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        
        super.init(container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
