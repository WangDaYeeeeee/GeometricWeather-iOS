//
//  ManagementTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/27.
//

import UIKit
import GeometricWeatherBasic

let locationCellHeight = 96.0
private let iconSize = 24.0

private let normalBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
private let selectedBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)

class LocationTableViewCell: UITableViewCell {
    
    // MARK: - subviews.
    
    private let highlightEffectContainer = UIView(frame: .zero)
    
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    
    private let currentTemperatureLabel = UILabel(frame: .zero)
    
    private let weatherSourceLabel = UILabel(frame: .zero)
    
    private let dailyTemperatureLabel = UILabel(frame: .zero)
    
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
        
        self.currentTemperatureLabel.textColor = .label
        self.currentTemperatureLabel.font = .systemFont(ofSize: 36.0, weight: .regular)
        self.highlightEffectContainer.addSubview(self.currentTemperatureLabel)
        
        self.weatherSourceLabel.textColor = .tertiaryLabel
        self.weatherSourceLabel.font = miniCaptionFont
        self.highlightEffectContainer.addSubview(self.weatherSourceLabel)
        
        self.dailyTemperatureLabel.textColor = .secondaryLabel
        self.dailyTemperatureLabel.font = bodyFont
        self.highlightEffectContainer.addSubview(self.dailyTemperatureLabel)
        
        self.highlightEffectContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.currentTemperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.dailyTemperatureLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(
                -(locationCellHeight + normalMargin)
            )
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(
                -(locationCellHeight + normalMargin)
            )
        }
        self.weatherSourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(
                -(locationCellHeight + normalMargin)
            )
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
        
        if let weather = location.weather {
            let tempUnit = SettingsManager.shared.temperatureUnit
            
            self.currentTemperatureLabel.text = tempUnit.formatValueWithUnit(
                weather.current.temperature.temperature,
                unit: "°"
            )
            self.dailyTemperatureLabel.text = getDayNightTemperatureText(
                daytimeTemperature: weather.dailyForecasts[0].day.temperature.temperature,
                nighttimeTemperature: weather.dailyForecasts[0].night.temperature.temperature,
                unit: tempUnit,
                reverseDayNightPosition: false,
                seperator: "/"
            )
            
            self.currentTemperatureLabel.alpha = 1.0
            self.dailyTemperatureLabel.alpha = 1.0
        } else {
            self.currentTemperatureLabel.alpha = 0.0
            self.dailyTemperatureLabel.alpha = 0.0
        }
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
