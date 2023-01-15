//
//  HourlyPrecipitationCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/18.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - generator.

class HourlyPrecipitationTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private let maxPrecipitationValue: Double
    private let histogramType: HourlyPrecipitationHistogramType
    
    // properties.
    
    var dispayName: String {
        switch self.histogramType {
            
        case .precipitationIntensity(_):
            return getLocalizedText("precipitation_intensity")
            
        default:
            return ""
        }
    }
    
    var isValid: Bool {
        return self.maxPrecipitationValue > 0.0
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var histogramType = DailyPrecipitationHistogramType.none
        var maxPrecipitationData = 0.0
        for hourly in location.weather?.hourlyForecasts ?? [] {
            if histogramType == .none {
                if hourly.precipitationIntensity != nil {
                    histogramType = .precipitationIntensity(max: 0.0)
                }
            }
            
            switch histogramType {
            case .precipitationIntensity(_):
                maxPrecipitationData = max(maxPrecipitationData, hourly.precipitationIntensity ?? 0.0)
                break
            default:
                break
            }
        }
        
        switch histogramType {
        case .precipitationIntensity(_):
            self.histogramType = .precipitationIntensity(max: maxPrecipitationData)
            self.maxPrecipitationValue = maxPrecipitationData
            break
        default:
            self.histogramType = .none
            self.maxPrecipitationValue = 0.0
            break
        }
    }
    
    // interfaces.
    
    static func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            HourlyPrecipitationCollectionViewCell.self,
            forCellWithReuseIdentifier: Self.key
        )
    }
    
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.key,
            for: indexPath
        )
        
        if let weather = self.location.weather,
           let cell = cell as? HourlyPrecipitationCollectionViewCell {
            
            var useAccentColorForDate = indexPath.row == 0
            if weather
               .hourlyForecasts[indexPath.row]
                .getHour(inTwelveHourFormat: false) == 0 {
                useAccentColorForDate = true
            }
            
            cell.bindData(
                hourly: weather.hourlyForecasts[indexPath.row],
                timezone: self.location.timezone,
                histogramType: self.histogramType,
                useAccentColorForDate: useAccentColorForDate
            )
            cell.trendPaddingTop = naturalTrendPaddingTop
            cell.trendPaddingBottom = naturalTrendPaddingBottom
        }
        
        return cell
    }
    
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView) {
        switch self.histogramType {
            
        case .precipitationIntensity(let max):
            let highLines = [
                (mmph: precipitationIntensityMiddle, desc: getLocalizedText("precipitation_middle")),
                (mmph: precipitationIntensityHeavy, desc: getLocalizedText("precipitation_heavy")),
                (mmph: precipitationIntensityRainstrom, desc: getLocalizedText("precipitation_rainstorm")),
            ].filter { item in
                item.mmph <= max
            }.map { item in
                HorizontalLine(
                    value: item.mmph / max,
                    leadingDescription: SettingsManager.shared.precipitationIntensityUnit.formatValue(item.mmph),
                    trailingDescription: item.desc
                )
            }
            trendBackgroundView.bindData(
                highLines: highLines,
                lowLines: [],
                lineColor: mainTrendBackgroundLineColor,
                paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
                paddingBottom: naturalTrendPaddingBottom + naturalBackgroundIconPadding
            )
            break
            
        default:
            trendBackgroundView.bindData(highLines: [], lowLines: [], lineColor: .clear)
            break
        }
    }
}

// MARK: - cell.

class HourlyPrecipitationCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
    private let trendView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
        
    var trendPaddingTop: CGFloat {
        get {
            return self.trendView.paddingTop
        }
        set {
            self.trendView.paddingTop = newValue
        }
    }
    
    var trendPaddingBottom: CGFloat {
        get {
            return self.trendView.paddingBottom
        }
        set {
            self.trendView.paddingBottom = newValue
        }
    }
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .label
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.contentView.addSubview(self.hourLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.hourlyIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.hourlyIcon)
        
        self.contentView.addSubview(self.trendView)
                
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.hourlyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.hourlyIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.trendView.snp.makeConstraints { make in
            make.top.equalTo(self.hourlyIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        hourly: Hourly,
        timezone: TimeZone,
        histogramType: HourlyPrecipitationHistogramType,
        useAccentColorForDate: Bool
    ) {
        self.hourLabel.text = getHourText(hourly)
        
        self.dateLabel.text = hourly.formatDate(
            format: getLocalizedText("date_format_short")
        )
        self.dateLabel.textColor = useAccentColorForDate
        ? .label
        : .tertiaryLabel
        self.dateLabel.font = useAccentColorForDate
        ? .systemFont(ofSize: miniCaptionFont.pointSize, weight: .bold)
        : miniCaptionFont
        
        self.hourlyIcon.image = UIImage.getWeatherIcon(
            weatherCode: hourly.weatherCode,
            daylight: hourly.daylight
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = hourly.precipitationProbability ?? 0.0
            if precipitationProb > 0 {
                self.trendView.highValue = min(precipitationProb / 100.0, 1.0)
                
                self.trendView.highDescription = (
                    getPercentTextWithoutUnit(
                        precipitationProb,
                        decimal: 0
                    ),
                    "%"
                )
                self.trendView.lowDescription = nil
            } else {
                self.trendView.highValue = nil
                
                self.trendView.highDescription = nil
                self.trendView.lowDescription = (
                    getPercentTextWithoutUnit(
                        precipitationProb,
                        decimal: 0
                    ),
                    "%"
                )
            }
            self.trendView.lowValue = nil
            
            self.trendView.color = getLevelColor(
                getPrecipitationProbLevel(precipitationProb)
            )
            break
            
        case .precipitationIntensity:
            let unit = SettingsManager.shared.precipitationIntensityUnit
            let precipitationIntensity = hourly.precipitationIntensity ?? 0.0
            if precipitationIntensity > 0 {
                self.trendView.highValue = min(
                    precipitationIntensity / precipitationIntensityHeavy,
                    1.0
                )
                
                self.trendView.highDescription = (
                    unit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: ""
                    ),
                    ""
                )
                self.trendView.lowDescription = nil
            } else {
                self.trendView.highValue = nil
                
                self.trendView.highDescription = nil
                self.trendView.lowDescription = (
                    unit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: ""
                    ),
                    ""
                )
            }
            self.trendView.lowValue = nil
            
            self.trendView.color = getLevelColor(
                getPrecipitationIntensityLevel(precipitationIntensity)
            )
            break
            
        case .none:
            self.trendView.highValue = nil
        }
    }
}
