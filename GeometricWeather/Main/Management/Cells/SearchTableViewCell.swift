//
//  SearchTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/3.
//

import UIKit
import GeometricWeatherBasic

private let iconSize = 24.0

private let normalBackgroundColor = UIColor.systemBackground
private let selectedBackgroundColor = UIColor.secondarySystemBackground

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - subviews.
    
    private let highlightEffectContainer = UIView(frame: .zero)
    
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    
    private let weatherSourceLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.highlightEffectContainer)
        
        self.titleLabel.textColor = .label
        self.titleLabel.font = largeTitleFont
        self.highlightEffectContainer.addSubview(self.titleLabel)
        
        self.subtitleLabel.textColor = .tertiaryLabel
        self.subtitleLabel.font = miniCaptionFont
        self.highlightEffectContainer.addSubview(self.subtitleLabel)
        
        self.weatherSourceLabel.textColor = .tertiaryLabel
        self.weatherSourceLabel.font = miniCaptionFont
        self.highlightEffectContainer.addSubview(self.weatherSourceLabel)
        
        self.highlightEffectContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.weatherSourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location, selected: Bool) {
        if (selected) {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = selectedBackgroundColor
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = normalBackgroundColor
            }
        }
        
        self.titleLabel.text = location.currentPosition
        ? NSLocalizedString("current_location", comment: "")
        : getLocationText(location: location)
        
        if location.residentPosition && location.weather != nil {
            self.titleLabel.setLeadingImage(
                UIImage(
                    systemName: "checkmark.seal.fill"
                )?.withTintColor(
                    .systemBlue
                ),
                andTrailingImage: .getWeatherIcon(
                    weatherCode: location.weather?.current.weatherCode ?? .clear,
                    daylight: location.daylight
                ),
                withText: self.titleLabel.text
            )
        } else if location.weather != nil {
            self.titleLabel.setTrailing(
                image: .getWeatherIcon(
                    weatherCode: location.weather?.current.weatherCode ?? .clear,
                    daylight: location.daylight
                ),
                withText: self.titleLabel.text
            )
        } else if location.residentPosition {
            self.titleLabel.setLeading(
                image: UIImage(
                    systemName: "checkmark.seal.fill"
                )?.withTintColor(
                    .systemBlue
                ),
                withText: self.titleLabel.text
            )
        } else {
            self.titleLabel.setLeading(
                image: nil,
                withText: self.titleLabel.text
            )
        }
        
        self.subtitleLabel.text = location.toString()
        
        self.weatherSourceLabel.text = "Powered by \(location.weatherSource.url)"
        self.weatherSourceLabel.textColor = .colorFromRGB(location.weatherSource.color)
    }
    
    // MARK: - selection.
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.highlightEffectContainer.alpha = 0.5
            
            UIView.animate(withDuration: 0.2) {
                self.highlightEffectContainer.transform = CGAffineTransform(
                    scaleX: 0.98,
                    y: 0.98
                )
            }
        } else {
            UIView.animate(withDuration: 0.45) {
                self.highlightEffectContainer.transform = CGAffineTransform(
                    scaleX: 1.0,
                    y: 1.0
                )
                self.highlightEffectContainer.alpha = 1.0
            }
        }
    }
}
