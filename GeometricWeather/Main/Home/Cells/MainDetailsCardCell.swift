//
//  MainDetailsCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/22.
//

import UIKit
import GeometricWeatherBasic

class MainDetailsCardCell: MainTableViewCell {
    
    // MARK: - data.
    
    private var weather: Weather?
    
    // MARK: - subviews.
    
    private let vstack = UIStackView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardTitle.text = NSLocalizedString("life_details", comment: "")
        
        self.vstack.axis = .vertical
        self.cardContainer.contentView.addSubview(self.vstack)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.vstack.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        if let weather = location.weather {
            self.weather = weather
            
            // remove all detail item view.
            for subview in self.vstack.arrangedSubviews {
                subview.removeFromSuperview()
            }
            
            // generate detial item views.
            
            // wind.
            if let wind = weather.dailyForecasts.get(0)?.wind {
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "wind",
                        title: NSLocalizedString("live", comment: "") + ": " + getWindText(
                            wind: weather.current.wind,
                            unit: SettingsManager.shared.speedUnit
                        ),
                        body: NSLocalizedString("today", comment: "") + ": " + getWindText(
                            wind: wind,
                            unit: SettingsManager.shared.speedUnit
                        )
                    )
                )
            } else if let daytime = weather.dailyForecasts.get(0)?.day.wind,
                      let nighttime = weather.dailyForecasts.get(0)?.night.wind {
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "wind",
                        title: NSLocalizedString("live", comment: "") + ": " + getWindText(
                            wind: weather.current.wind,
                            unit: SettingsManager.shared.speedUnit
                        ),
                        body: NSLocalizedString("daytime", comment: "") + ": " + getWindText(
                            wind: daytime,
                            unit: SettingsManager.shared.speedUnit
                        ) + "\n" + NSLocalizedString("nighttime", comment: "") + ": " + getWindText(
                            wind: nighttime,
                            unit: SettingsManager.shared.speedUnit
                        )
                    )
                )
            }
            
            // humidity.
            if let humidity = weather.current.relativeHumidity {
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "humidity",
                        title: NSLocalizedString("humidity", comment: ""),
                        body: getPercentText(
                            humidity,
                            decimal: 1
                        )
                    )
                )
            }
            
            // uv.
            if weather.current.uv.isValid() {
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "sun.max",
                        title: NSLocalizedString("uv_index", comment: ""),
                        body: weather.current.uv.getUVDescription()
                    )
                )
            }
            
            // pressure.
            if let pressure = weather.current.pressure {
                let unit = SettingsManager.shared.pressureUnit
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "gauge",
                        title: NSLocalizedString("pressure", comment: ""),
                        body: unit.formatValueWithUnit(
                            pressure,
                            unit: NSLocalizedString(unit.key, comment: "")
                        )
                    )
                )
            }
            
            // visibility.
            if let visibility = weather.current.visibility {
                let unit = SettingsManager.shared.distanceUnit
                self.vstack.addArrangedSubview(
                    self.generateDetailItemView(
                        iconName: "eye",
                        title: NSLocalizedString("visibility", comment: ""),
                        body: unit.formatValueWithUnit(
                            visibility,
                            unit: NSLocalizedString(unit.key, comment: "")
                        )
                    )
                )
            }
        }
    }
    
    // MARK: - ui.
    
    private func generateDetailItemView(
        iconName: String,
        title: String,
        body: String
    ) -> MainDetailItemView {
        let view = MainDetailItemView(frame: .zero)
        view.bindData(iconName: iconName, title: title, body: body)
        return view
    }
}

