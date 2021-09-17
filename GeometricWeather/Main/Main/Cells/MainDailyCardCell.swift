//
//  MainDailyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit

private let trendReuseIdentifier = "daily_trend_cell"
private let dailyTrendViewHeight = 324

class MainDailyCardCell: MainTableViewCell,
                            UICollectionViewDataSource {
    
    // MARK: - data.
    
    var mainTimeBarDelegate: MainTimeBarDelegate? {
        get {
            return self.timeBar.delegate
        }
        set {
            self.timeBar.delegate = newValue
        }
    }
    
    private var weather: Weather?
    private var timezone: TimeZone?
    private var temperatureRange: TemperatureRange?
    
    // MARK: - subviews.
    
    private let timeBar = MainTimeBarView()
    private let summaryLabel = UILabel(frame: .zero)
    
    private let dailyBackgroundView = DailyTrendCellBackgroundView(frame: .zero)
    private let dailyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardContainer.contentView.addSubview(self.timeBar)
        
        self.cardTitle.text = NSLocalizedString("daily_overview", comment: "")
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.cardContainer.contentView.addSubview(self.summaryLabel)
        
        self.dailyCollectionView.dataSource = self
        self.dailyCollectionView.register(
            DailyTrendCollectionViewCell.self,
            forCellWithReuseIdentifier: trendReuseIdentifier
        )
        self.cardContainer.contentView.addSubview(self.dailyCollectionView)
        
        self.dailyBackgroundView.isUserInteractionEnabled = false
        self.cardContainer.contentView.addSubview(self.dailyBackgroundView)
        
        self.timeBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalTo(self.timeBar.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.dailyBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.summaryLabel.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(dailyTrendViewHeight)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        self.dailyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.dailyBackgroundView.snp.top)
            make.leading.equalTo(self.dailyBackgroundView.snp.leading)
            make.trailing.equalTo(self.dailyBackgroundView.snp.trailing)
            make.bottom.equalTo(self.dailyBackgroundView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location) {
        super.bindData(location: location)
        
        if let weather = location.weather {
            self.weather = weather
            self.timezone = location.timezone
            
            var maxTemp = weather.yesterday?.daytimeTemperature ?? Int.min
            var minTemp = weather.yesterday?.nighttimeTemperature ?? Int.max
            for daily in weather.dailyForecasts {
                if maxTemp < daily.day.temperature.temperature {
                    maxTemp = daily.day.temperature.temperature
                }
                if minTemp > daily.night.temperature.temperature {
                    minTemp = daily.night.temperature.temperature
                }
            }
            self.temperatureRange = (minTemp, maxTemp)
            
            self.timeBar.register(
                weather: weather,
                andTimezone: location.timezone
            )
            
            self.summaryLabel.text = weather.current.dailyForecast
            
            self.dailyBackgroundView.bindData(
                weather: weather,
                temperatureRange: self.temperatureRange ?? (0, 0)
            )
            
            self.dailyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .left,
                animated: false
            )
            self.dailyCollectionView.collectionViewLayout.invalidateLayout()
            self.dailyCollectionView.reloadData()
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.dailyCollectionView.reloadData()
            
            if let weather = self.weather,
               let range = self.temperatureRange {
                self.dailyBackgroundView.bindData(weather: weather, temperatureRange: range)
            }
        }
    }
    
    // MARK: - interfaces.
    
    func registerScrollDelegate(delegate: UIScrollViewDelegate?) {
        
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width / CGFloat(getTrenItemDisplayCount()),
            height: collectionView.frame.height
        )
    }
    
    // data source.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return weather?.dailyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = self.dailyCollectionView.dequeueReusableCell(
            withReuseIdentifier: trendReuseIdentifier,
            for: indexPath
        )
        if let weather = self.weather,
            let dailies = self.weather?.dailyForecasts {
            (cell as? DailyTrendCollectionViewCell)?.bindData(
                prev: indexPath.row == 0 ? nil : dailies[indexPath.row - 1],
                daily: dailies[indexPath.row],
                next: indexPath.row == dailies.count - 1 ? nil : dailies[indexPath.row + 1],
                temperatureRange: self.temperatureRange ?? (0, 0),
                weatherCode: weather.current.weatherCode,
                timezone: self.timezone ?? .current
            )
        }
        return cell
    }
}
