//
//  StatementDialog.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/18.
//

import Foundation
import GeometricWeatherBasic

class StatementDialog: GeoDialog {
    
    private let titleLabel = UILabel(frame: .zero)
    private let contentLabel = UILabel(frame: .zero)
    
    init(title: String, content: String) {
        let container = UIView(frame: .zero)
        
        let vstack = UIStackView(frame: .zero)
        vstack.alignment = .center
        vstack.axis = .vertical
        vstack.spacing = normalMargin
        container.addSubview(vstack)
        
        self.titleLabel.text = title
        self.titleLabel.textColor = .label
        self.titleLabel.font = largeTitleFont
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.numberOfLines = 0
        vstack.addArrangedSubview(self.titleLabel)
        
        self.contentLabel.text = content
        self.contentLabel.textColor = .secondaryLabel
        self.contentLabel.font = bodyFont
        self.contentLabel.lineBreakMode = .byWordWrapping
        self.contentLabel.numberOfLines = 0
        vstack.addArrangedSubview(self.contentLabel)
        
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
