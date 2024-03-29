//
//  DailyUVCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/24.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - generator.

class DailyUVTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private var maxUVIndex: Int
    
    // properties.
    
    var dispayName: String {
        return getLocalizedText("uv_index")
    }
    
    var isValid: Bool {
        return self.maxUVIndex > 0
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var maxUV = 0
        location.weather?.dailyForecasts.forEach { daily in
            if maxUV < daily.uv.index ?? 0 {
                maxUV = daily.uv.index ?? 0
            }
        }
        self.maxUVIndex = maxUV
    }
    
    // interfaces.
    
    static func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            DailyUVCollectionViewCell.self,
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
           let cell = cell as? DailyUVCollectionViewCell {
            cell.bindData(
                daily: weather.dailyForecasts[indexPath.row],
                maxAqiIndex: self.maxUVIndex,
                timezone: self.location.timezone
            )
            cell.trendPaddingTop = naturalTrendPaddingTop
            cell.trendPaddingBottom = naturalTrendPaddingBottom
        }
        
        return cell
    }
    
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView) {
        let highLines = [
            uvIndexLevelLow,
            uvIndexLevelMiddle,
            uvIndexLevelHigh,
        ].filter { item in
            item <= maxUVIndex
        }.map { item in
            HorizontalLine(
                value: Double(item) / Double(maxUVIndex),
                leadingDescription: String(item),
                trailingDescription: ""
            )
        }
        trendBackgroundView.bindData(
            highLines: highLines,
            lowLines: [],
            lineColor: mainTrendBackgroundLineColor,
            paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
            paddingBottom: naturalTrendPaddingBottom
        )
    }
}

// MARK: - cell.

class DailyUVCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let histogramView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
    
    var trendPaddingTop: CGFloat {
        get {
            return self.histogramView.paddingTop
        }
        set {
            self.histogramView.paddingTop = newValue
        }
    }
    
    var trendPaddingBottom: CGFloat {
        get {
            return self.histogramView.paddingBottom
        }
        set {
            self.histogramView.paddingBottom = newValue
        }
    }
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.weekLabel.font = bodyFont
        self.weekLabel.textColor = .label
        self.weekLabel.textAlignment = .center
        self.weekLabel.numberOfLines = 1
        self.contentView.addSubview(self.weekLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.contentView.addSubview(self.histogramView)
        
        self.weekLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.weekLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.histogramView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(
                littleMargin + mainTrendIconSize
            )
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        daily: Daily,
        maxAqiIndex: Int,
        timezone: TimeZone
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(daily)
        
        self.dateLabel.text = daily.getDate(
            format: getLocalizedText("date_format_short")
        )
        
        if maxAqiIndex > 0 {
            self.histogramView.highValue = Double(
                (daily.uv.index ?? 0)
            ) / Double(
                maxAqiIndex
            )
        } else {
            self.histogramView.highValue = 0.0
        }
        self.histogramView.lowValue = nil
        
        self.histogramView.highDescription = (
            daily.uv.index?.description ?? "",
            ""
        )
        self.histogramView.color = getLevelColor(
            daily.uv.getUVLevel()
        )
    }
}
