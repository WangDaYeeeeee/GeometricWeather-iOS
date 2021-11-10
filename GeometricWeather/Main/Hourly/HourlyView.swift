//
//  HourlyView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/10.
//

import Foundation
import GeometricWeatherBasic

private let headerIconSize = 44.0

class HourlyView: UIView {
    
    init(weather: Weather, timezone: TimeZone, index: Int) {
        super.init(frame: .zero)
        
        let vstack = UIStackView(frame: .zero)
        vstack.alignment = .leading
        vstack.axis = .vertical
        vstack.spacing = normalMargin
        self.addSubview(vstack)
        
        if let hourly = weather.hourlyForecasts.get(index) {
            
            // stack 1.
            
            let stack1 = UIStackView(frame: .zero)
            stack1.alignment = .leading
            stack1.axis = .vertical
            stack1.spacing = 0
            vstack.addArrangedSubview(stack1)
            
            let titleLabel = UILabel(frame: .zero)
            titleLabel.text = getHourText(
                hour: hourly.getHour(
                    isTwelveHour(),
                    timezone: timezone
                )
            )
            titleLabel.textColor = .label
            titleLabel.font = largeTitleFont
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.numberOfLines = 0
            stack1.addArrangedSubview(titleLabel)
            
            let subtitleLabel = UILabel(frame: .zero)
            subtitleLabel.text = hourly.formatDate(
                format: NSLocalizedString(
                    "date_format_widget_long",
                    comment: ""
                )
            )
            subtitleLabel.textColor = .tertiaryLabel
            subtitleLabel.font = captionFont
            subtitleLabel.lineBreakMode = .byWordWrapping
            subtitleLabel.numberOfLines = 0
            stack1.addArrangedSubview(subtitleLabel)
            
            // stack 2.
            
            let stack2 = UIStackView(frame: .zero)
            stack2.alignment = .leading
            stack2.axis = .vertical
            stack2.spacing = 0
            vstack.addArrangedSubview(stack2)
            
            let header = HourlyHeaderView(hourly)
            stack2.addArrangedSubview(header)
            header.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            
            if let precipitationIntensity = hourly.precipitationIntensity {
                let precipitationIntensityUnit = SettingsManager.shared.precipitationIntensityUnit
                
                let item = HourlyItemView(
                    title: NSLocalizedString(
                        "precipitation_intensity",
                        comment: ""
                    ),
                    content: precipitationIntensityUnit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: NSLocalizedString(
                            precipitationIntensityUnit.key,
                            comment: ""
                        )
                    )
                )
                stack2.addArrangedSubview(item)
                item.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                }
            }
            if let precipitationProb = hourly.precipitationProbability {
                if precipitationProb > 0 {
                    let item = HourlyItemView(
                        title: NSLocalizedString("precipitation_probability", comment: ""),
                        content: "\(Int(precipitationProb))%"
                    )
                    stack2.addArrangedSubview(item)
                    item.snp.makeConstraints { make in
                        make.leading.equalToSuperview()
                        make.trailing.equalToSuperview()
                    }
                }
            }
            if let wind = hourly.wind {
                let item = HourlyItemView(
                    title: NSLocalizedString("wind", comment: ""),
                    content: getWindText(
                        wind: wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
                stack2.addArrangedSubview(item)
                item.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                }
            }
        }
        
        vstack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private class HourlyHeaderView: UIView {
    
    private let iconImage = UIImageView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    
    init(_ hourly: Hourly) {
        super.init(frame: .zero)
        
        self.iconImage.image = UIImage.getWeatherIcon(
            weatherCode: hourly.weatherCode,
            daylight: hourly.daylight
        )?.scaleToSize(
            CGSize(
                width: headerIconSize,
                height: headerIconSize
            )
        )
        self.addSubview(self.iconImage)
        
        let tempUnit = SettingsManager.shared.temperatureUnit
        self.titleLabel.text = hourly.weatherText
        + ", "
        + tempUnit.formatValueWithUnit(
            hourly.temperature.temperature,
            unit: NSLocalizedString(tempUnit.key, comment: "")
        )
        self.titleLabel.textColor = .label
        self.titleLabel.font = titleFont
        self.titleLabel.numberOfLines = 1
        self.addSubview(self.titleLabel)
        
        self.iconImage.snp.makeConstraints { make in
            make.size.equalTo(headerIconSize)
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.iconImage.snp.trailing).offset(littleMargin)
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class HourlyItemView: UIView {
    
    private let titleLabel = UILabel(frame: .zero)
    private let contentLabel = UILabel(frame: .zero)
    
    init(title: String, content: String) {
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        self.titleLabel.textColor = .tertiaryLabel
        self.titleLabel.font = captionFont
        self.titleLabel.numberOfLines = 1
        self.addSubview(self.titleLabel)
        
        self.contentLabel.text = content
        self.contentLabel.textColor = .secondaryLabel
        self.contentLabel.font = bodyFont
        self.contentLabel.numberOfLines = 0
        self.contentLabel.lineBreakMode = .byWordWrapping
        self.addSubview(self.contentLabel)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
