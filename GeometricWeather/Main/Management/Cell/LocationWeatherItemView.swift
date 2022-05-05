//
//  WeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/27.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class LocationWeatherItemView: UIView {
    
    private let firstRow = UIView(frame: .zero)
    private let weatherIcon = UIImageView(frame: .zero)
    private let residientIcon = UIImageView(frame: .zero)
    
    private let titleContainer = UILabel(frame: .zero)
    private let titleLabel1 = UILabel(frame: .zero)
    private let titleLabel2 = UILabel(frame: .zero)
    
    private let subtitleLabel = UILabel(frame: .zero)
    private let sourceLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.firstRow.backgroundColor = .clear
        self.addSubview(self.firstRow)
        
        self.weatherIcon.contentMode = .scaleAspectFill
        self.firstRow.addSubview(self.weatherIcon)
        
        self.residientIcon.contentMode = .scaleAspectFill
        self.residientIcon.image = UIImage(
            systemName: "checkmark.seal.fill"
        )?.withTintColor(
            .systemBlue
        )
        self.firstRow.addSubview(self.residientIcon)
        
        self.titleContainer.backgroundColor = .clear
        self.firstRow.addSubview(self.titleContainer)
        
        self.titleLabel1.font = largeTitleFont
        self.titleLabel1.textColor = .label
        self.titleLabel1.numberOfLines = 1
        self.titleContainer.addSubview(self.titleLabel1)
        
        self.titleLabel2.font = bodyFont
        self.titleLabel2.textColor = .secondaryLabel
        self.titleLabel2.numberOfLines = 1
        self.titleContainer.addSubview(self.titleLabel2)
        
        self.subtitleLabel.font = miniCaptionFont
        self.subtitleLabel.textColor = .tertiaryLabel
        self.subtitleLabel.numberOfLines = 1
        self.addSubview(self.subtitleLabel)
        
        self.sourceLabel.font = .systemFont(ofSize: miniCaptionFont.pointSize, weight: .bold)
        self.sourceLabel.textColor = .systemBlue
        self.sourceLabel.numberOfLines = 1
        self.addSubview(self.sourceLabel)
        
        self.firstRow.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.weatherIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(46.0)
        }
        self.residientIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(20.0)
        }
        self.titleContainer.snp.makeConstraints { make in
            make.leading.equalTo(self.weatherIcon.snp.trailing).offset(littleMargin)
            make.trailing.equalTo(self.residientIcon.snp.leading).offset(-littleMargin)
            make.top.equalToSuperview().offset(littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.titleLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.titleLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel1.snp.bottom)
            make.bottom.equalToSuperview()
        }
        self.sourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalTo(self.sourceLabel.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location) {
        guard let weather = location.weather else {
            return
        }
        
        self.weatherIcon.image = UIImage.getWeatherIcon(
            weatherCode: weather.current.weatherCode,
            daylight: location.daylight
        )
        self.residientIcon.alpha = location.residentPosition ? 1 : 0
        self.titleLabel1.text = location.currentPosition
        ? getLocalizedText("current_location")
        : getLocationText(location: location)
        self.titleLabel2.text = weather.current.weatherText
        + ", "
        + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
            weather.current.temperature.temperature,
            unit: "º"
        )
        self.subtitleLabel.text = location.toString()
        self.sourceLabel.text = "Powered by \(location.weatherSource.url)"
        self.sourceLabel.textColor = UIColor.colorFromRGB(location.weatherSource.color)
    }
}
