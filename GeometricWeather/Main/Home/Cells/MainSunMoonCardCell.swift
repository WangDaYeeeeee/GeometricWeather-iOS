//
//  MainSunMoonCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/21.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let iconSize = 20.0

private let innerMargin = 4.0

class MainSunMoonCardCell: MainTableViewCell {
    
    // MARK: - subviews.
    
    private let moonPhaseView = MoonPhaseView(frame: .zero)
    private let moonPhaseLabel = UILabel(frame: .zero)
    
    private let sunMoonPathView = SunMoonPathView(frame: .zero)
    
    private let sunIcon = UIImageView(frame: .zero)
    private let sunLabel = UILabel(frame: .zero)
    
    private let moonIcon = UIImageView(frame: .zero)
    private let moonLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardTitle.text = getLocalizedText("sunrise_sunset")
        
        self.cardContainer.contentView.addSubview(self.moonPhaseView)
        
        self.moonPhaseLabel.font = bodyFont
        self.moonPhaseLabel.textColor = .label
        self.cardContainer.contentView.addSubview(self.moonPhaseLabel)
        
        self.cardContainer.contentView.addSubview(self.sunMoonPathView)
        
        self.sunIcon.image = UIImage.getSunIcon()?.scaleToSize(
            CGSize(
                width: iconSize,
                height: iconSize
            )
        )
        self.sunIcon.contentMode = .scaleAspectFit
        self.cardContainer.contentView.addSubview(self.sunIcon)
        
        self.sunLabel.font = miniCaptionFont
        self.sunLabel.textColor = .secondaryLabel
        self.sunLabel.numberOfLines = 2
        self.cardContainer.contentView.addSubview(self.sunLabel)
        
        self.moonIcon.image = UIImage.getMoonIcon()?.scaleToSize(
            CGSize(
                width: iconSize,
                height: iconSize
            )
        )
        self.moonIcon.contentMode = .scaleAspectFit
        self.cardContainer.contentView.addSubview(self.moonIcon)
        
        self.moonLabel.font = miniCaptionFont
        self.moonLabel.textAlignment = isRtl ? .left : .right
        self.moonLabel.textColor = .secondaryLabel
        self.moonLabel.numberOfLines = 2
        self.cardContainer.contentView.addSubview(self.moonLabel)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.moonPhaseView.snp.makeConstraints { make in
            make.size.equalTo(iconSize)
            make.centerY.equalTo(self.titleVibrancyContainer.snp.centerY)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.moonPhaseLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleVibrancyContainer.snp.centerY)
            make.trailing.equalTo(self.moonPhaseView.snp.leading).offset(-innerMargin)
        }
        self.sunMoonPathView.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.height.equalTo(136)
        }
        self.sunIcon.snp.makeConstraints { make in
            make.top.equalTo(self.sunMoonPathView.snp.bottom).offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.size.equalTo(iconSize)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        self.sunLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.sunIcon.snp.trailing).offset(innerMargin)
            make.centerY.equalTo(self.sunIcon.snp.centerY)
        }
        self.moonIcon.snp.makeConstraints { make in
            make.top.equalTo(self.sunMoonPathView.snp.bottom).offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.size.equalTo(iconSize)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        self.moonLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.moonIcon.snp.leading).offset(-innerMargin)
            make.centerY.equalTo(self.moonIcon.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        guard let weather = location.weather else {
            return
        }
        
        // moon phase.
        
        if let angle = weather.dailyForecasts[0].moonPhase.angle,
            let _ = weather.dailyForecasts[0].moonPhase.description {
            self.moonPhaseView.alpha = 1.0
            self.moonPhaseLabel.alpha = 1.0
            
            self.moonPhaseView.angle = Double(angle)
            self.moonPhaseView.lightColor = .white
            
            self.moonPhaseLabel.text = getLocalizedText(
                weather.dailyForecasts[0].moonPhase.getMoonPhaseKey()
            )
        } else {
            self.moonPhaseView.alpha = 0.0
            self.moonPhaseLabel.alpha = 0.0
        }
        
        // sun moon path view.
        
        self.sunMoonPathView.sunIconImage = UIImage.getSunIcon()
        self.sunMoonPathView.moonIconImage = UIImage.getMoonIcon()
        
        // sun moon description.
        
        if let riseTime = weather.dailyForecasts[0].sun.riseTime,
            let setTime = weather.dailyForecasts[0].sun.setTime {
            self.sunIcon.alpha = 1.0
            self.sunLabel.alpha = 1.0
            
            self.sunLabel.text = formateTime(
                timeIntervalSine1970: riseTime,
                twelveHour: isTwelveHour()
            ) + "↑" + "\n" + formateTime(
                timeIntervalSine1970: setTime,
                twelveHour: isTwelveHour()
            ) + "↓"
        } else {
            self.sunIcon.alpha = 0.0
            self.sunLabel.alpha = 0.0
        }
        if let riseTime = weather.dailyForecasts[0].moon.riseTime,
            let setTime = weather.dailyForecasts[0].moon.setTime {
            self.moonIcon.alpha = 1.0
            self.moonLabel.alpha = 1.0
            
            self.moonLabel.text = formateTime(
                timeIntervalSine1970: riseTime,
                twelveHour: isTwelveHour()
            ) + "↑" + "\n" + formateTime(
                timeIntervalSine1970: setTime,
                twelveHour: isTwelveHour()
            ) + "↓"
        } else {
            self.moonIcon.alpha = 0.0
            self.moonLabel.alpha = 0.0
        }
        
        // theme colors.
        let color = ThemeManager.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
            daylight: location.isDaylight
        )
        
        self.moonPhaseView.lightColor = UIColor(color * 0.5 + .white * 0.5)
        self.moonPhaseView.darkColor = UIColor(color)
        self.moonPhaseView.borderColor = UIColor(color)
        
        self.sunMoonPathView.sunColor = UIColor(color)
        self.sunMoonPathView.moonColor = UIColor(color)
        self.sunMoonPathView.backgroundLineColor = UIColor(color)
    }
    
    override func staggeredScrollIntoScreen(atFirstTime: Bool) {
        if atFirstTime {
            var sunProgress = -1.0
            if self.location?.weather?.dailyForecasts.get(0)?.sun.isValid() == true {
                sunProgress = Astro.getRiseProgress(
                    for: self.location?.weather?.dailyForecasts.get(0)?.sun,
                    in: self.location?.timezone ?? .current
                ).keepIn(range: 0...1)
            }
            
            var moonProgress = -1.0
            if self.location?.weather?.dailyForecasts.get(0)?.moon.isValid() == true {
                moonProgress = Astro.getRiseProgress(
                    for: self.location?.weather?.dailyForecasts.get(0)?.moon,
                    in: self.location?.timezone ?? .current
                ).keepIn(range: 0...1)
            }
            
            self.sunMoonPathView.setProgress(
                (sunProgress, moonProgress),
                withAnimationDuration: (
                    sunProgress == -1.0 ? -1.0 : (2.0 + sunProgress * 3.0),
                    moonProgress == -1.0 ? -1.0 : (2.0 * moonProgress * 3.0)
                )
            )
        }
    }
}
