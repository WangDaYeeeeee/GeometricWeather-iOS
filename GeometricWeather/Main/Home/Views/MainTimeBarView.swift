//
//  MainTimeBar.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/9.
//

import UIKit
import SnapKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct TimeBarManagementAction {}
struct TimeBarAlertAction {}

class MainTimeBarView: UIStackView {
    
    // MARK: - properties.
    
    // subviews.
    
    private let timeHStack = UIStackView(frame: .zero)
    
    private let leadingIcon = ImageButtonEffect(frame: .zero)
    
    private let timeLabelVStack = UIStackViewEffect(frame: .zero)
    private let updateTimeLabel = UILabel(frame: .zero)
    private let timezoneTimeLabel = UILabel(frame: .zero)
    
    private let alertsLabel = UILabelEffect(frame: .zero)
    
    // data.
    
    private var timezone: TimeZone = .current
    private var timer: Timer?
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.axis = .vertical
        self.alignment = .leading
        
        self.timeHStack.axis = .horizontal
        self.timeHStack.alignment = .center
        self.timeHStack.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.managementAction)
            )
        )
        self.addArrangedSubview(self.timeHStack)
        
        self.leadingIcon.tintColor = .label
        self.leadingIcon.addTarget(
            self,
            action: #selector(self.alertAction),
            for: .touchUpInside
        )
        self.timeHStack.addArrangedSubview(self.leadingIcon)
        
        self.timeLabelVStack.axis = .vertical
        self.timeLabelVStack.alignment = .leading
        self.timeHStack.addArrangedSubview(self.timeLabelVStack)

        self.updateTimeLabel.font = titleFont
        self.updateTimeLabel.textColor = .label
        self.timeLabelVStack.addArrangedSubview(self.updateTimeLabel)
        
        self.timezoneTimeLabel.font = miniCaptionFont
        self.timezoneTimeLabel.textColor = .tertiaryLabel
        
        self.alertsLabel.font = miniCaptionFont
        self.alertsLabel.textColor = .secondaryLabel
        self.alertsLabel.numberOfLines = 0
        self.alertsLabel.lineBreakMode = .byWordWrapping
        self.alertsLabel.isUserInteractionEnabled = true
        self.alertsLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.alertAction)
            )
        )
        
        self.timeHStack.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.leadingIcon.snp.makeConstraints { make in
            make.size.equalTo(56.0)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - interface.
    
    func register(weather: Weather, andTimezone timezone: TimeZone) {
        self.timezone = timezone
        
        self.timezoneTimeLabel.removeFromSuperview()
        self.alertsLabel.removeFromSuperview()
        
        self.leadingIcon.setImage(
            UIImage(
                systemName: weather.alerts.isEmpty
                ? "clock"
                : "exclamationmark.circle"
            ),
            for: .normal
        )
        self.leadingIcon.isUserInteractionEnabled = !weather.alerts.isEmpty
        
        self.updateTimeLabel.text = getLocalizedText("refresh_at")
        + ": "
        + weather.base.formatePublishTime(twelveHour: isTwelveHour())
        
        if timezone != .current {
            self.timezoneTimeLabel.text = Self.getLocalTimeText(
                timestamp: Date().timeIntervalSince1970,
                timezone: timezone
            )
            self.timeLabelVStack.addArrangedSubview(self.timezoneTimeLabel)
        }
        
        if !weather.alerts.isEmpty {
            var alertsText = ""
            for (i, alert) in weather.alerts.enumerated() {
                if i != 0 {
                    alertsText += "\n"
                }
                
                alertsText += alert.description
                + ", "
                + DateFormatter.localizedString(
                    from: Date(timeIntervalSince1970: alert.time),
                    dateStyle: .medium,
                    timeStyle: .none
                )
            }
            self.alertsLabel.text = alertsText
            self.alertsLabel.attributedText = alertsText.toAttributedString(
                withLineSpaceing: 2.0
            )
            
            self.addArrangedSubview(self.alertsLabel)
            self.alertsLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(normalMargin)
                make.trailing.equalToSuperview().offset(-normalMargin)
            }
        }
        
        if timezone != .current && timer == nil {
            timer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { [weak self] _ in
                self?.timezoneTimeLabel.text = Self.getLocalTimeText(
                    timestamp: Date().timeIntervalSince1970,
                    timezone: self?.timezone ?? .current
                )
            }
        } else if timezone == .current && timer != nil {
            unregister()
        }
    }
    
    func unregister() {
        timer?.invalidate()
        timer = nil
    }
    
    private static func getLocalTimeText(
        timestamp: TimeInterval,
        timezone: TimeZone
    ) -> String {
        return getLocalizedText("local_time")
        + ": "
        + formateTime(
            timeIntervalSine1970: timestamp,
            twelveHour: isTwelveHour(),
            timezone: timezone
        )
    }
    
    // MARK: - actions.
    
    @objc private func managementAction() {
        self.window?.windowScene?.eventBus.post(TimeBarManagementAction())
    }
    
    @objc private func alertAction() {
        self.window?.windowScene?.eventBus.post(TimeBarAlertAction())
    }
}
