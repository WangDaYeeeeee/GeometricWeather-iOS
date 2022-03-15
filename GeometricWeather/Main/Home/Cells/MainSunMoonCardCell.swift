//
//  MainSunMoonCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/21.
//

import UIKit
import GeometricWeatherBasic

private let iconSize = 20.0

private let innerMargin = 4.0

class MainSunMoonCardCell: MainTableViewCell {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    
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
        
        self.cardTitle.text = NSLocalizedString("sunrise_sunset", comment: "")
        
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
        
        ThemeManager.shared.daylight.addNonStickyObserver(
            self
        ) { [weak self] daylight in
            guard let weather = self?.weather else {
                return
            }
            
            self?.updateThemeColors(
                weatherCode: weather.current.weatherCode,
                daylight: daylight
            )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        if let weather = location.weather {
            self.weather = weather
            self.timezone = location.timezone
            
            // moon phase.
            
            if let angle = weather.dailyForecasts[0].moonPhase.angle,
                let _ = weather.dailyForecasts[0].moonPhase.description {
                self.moonPhaseView.alpha = 1.0
                self.moonPhaseLabel.alpha = 1.0
                
                self.moonPhaseView.angle = Double(angle)
                self.moonPhaseView.lightColor = .white
                
                self.moonPhaseLabel.text = NSLocalizedString(
                    weather.dailyForecasts[0].moonPhase.getMoonPhaseKey(),
                    comment: ""
                )
            } else {
                self.moonPhaseView.alpha = 0.0
                self.moonPhaseLabel.alpha = 0.0
            }
            
            // sun moon path view.
        
            self.sunMoonPathView.setProgress(
                (0.0, 0.0),
                withAnimationDuration: (0.0, 0.0)
            )
            
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
            
            self.updateThemeColors(
                weatherCode: weather.current.weatherCode,
                daylight: ThemeManager.shared.daylight.value
            )
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
            if let weatherCode = self.weather?.current.weatherCode {
                self.updateThemeColors(
                    weatherCode: weatherCode,
                    daylight: ThemeManager.shared.daylight.value
                )
            }
        }
    }
    
    private func updateThemeColors(weatherCode: WeatherCode, daylight: Bool) {
        let color = ThemeManager.shared.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(code: weatherCode),
            daylight: daylight
        )
        
        self.moonPhaseView.darkColor = color
        self.moonPhaseView.borderColor = self.traitCollection.userInterfaceStyle == .light
        ? self.moonPhaseView.darkColor
        : self.moonPhaseView.lightColor
        
        self.sunMoonPathView.sunColor = color
        self.sunMoonPathView.moonColor = color
        self.sunMoonPathView.backgroundLineColor = color
    }
    
    override func staggeredScrollIntoScreen(atFirstTime: Bool) {
        if atFirstTime {
            var sunProgress = -1.0
            var moonProgress = -1.0
            if let riseTime = weather?.dailyForecasts[0].sun.riseTime,
                let setTime = weather?.dailyForecasts[0].sun.setTime {
                sunProgress = getPathProgress(
                    riseTime: riseTime,
                    setTime: setTime,
                    timezone: timezone ?? .current
                )
            }
            if let riseTime = weather?.dailyForecasts[0].moon.riseTime,
                let setTime = weather?.dailyForecasts[0].moon.setTime {
                moonProgress = getPathProgress(
                    riseTime: riseTime,
                    setTime: setTime,
                    timezone: timezone ?? .current
                )
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

// MARK: - ui.

private func getPathProgress(
    riseTime: TimeInterval,
    setTime: TimeInterval,
    timezone: TimeZone
) -> Double {
    let riseDate = Date(timeIntervalSince1970: riseTime)
    let riseHourMinutes = Calendar.current.component(
        .hour, from: riseDate
    ) * 60 + Calendar.current.component(
        .minute, from: riseDate
    )
    
    let setDate = Date(timeIntervalSince1970: setTime)
    let setHourMinutes = Calendar.current.component(
        .hour, from: setDate
    ) * 60 + Calendar.current.component(
        .minute, from: setDate
    )
    
    let timezoneDate = Date(
        timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
        )
    )
    let timezoneHourMinutes = Calendar.current.component(
        .hour, from: timezoneDate
    ) * 60 + Calendar.current.component(
        .minute, from: timezoneDate
    )

    var progress = 0.0
    if (setHourMinutes > riseHourMinutes) {
        progress = Double(
            timezoneHourMinutes - riseHourMinutes
        ) / Double(
            setHourMinutes - riseHourMinutes
        );
    } else if (timezoneHourMinutes <= setHourMinutes) {
        // for example: 23:00 rise, 07:00 set, 05:00 currently.
        progress = Double(
            timezoneHourMinutes - riseHourMinutes + 24 * 60
        ) / Double(
            setHourMinutes - riseHourMinutes + 24 * 60
        );
    } else if (timezoneHourMinutes < riseHourMinutes) {
        // for example: 23:00 rise, 07:00 set, 13:00 currently.
        progress = 0.0;
    } else {
        // for example: 23:00 rise, 07:00 set, 23:23 currently.
        progress = Double(
            timezoneHourMinutes - riseHourMinutes
        ) / Double(
            setHourMinutes - riseHourMinutes + 24 * 60
        );
    }

    progress = max(0.0, progress);
    progress = min(1.0, progress);
    return progress;
}
