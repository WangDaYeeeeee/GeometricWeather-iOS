//
//  MainAirQualityCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/20.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let circularProgressSize = 156.0
private let linearProgressHeight = 36.0

class MainAirQualityCardCell: MainTableViewCell {
    
    // MARK: - data.
    
    private var weather: Weather?
    
    // MARK: - subviews.
    
    private let hstack = UIStackView(frame: .zero)
    
    private let circularProgressView = CircularProgressView(frame: .zero)
    
    private let vstack = UIStackView(frame: .zero)
    private var linearProgressViews = [(
        progress: Double,
        color: UIColor,
        view: LinearProgressView
    )]()
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardTitle.text = getLocalizedText("air_quality")
        
        self.hstack.axis = .horizontal
        self.hstack.alignment = .center
        self.hstack.spacing = normalMargin
        self.cardContainer.contentView.addSubview(self.hstack)
        
        self.hstack.addArrangedSubview(self.circularProgressView)
        
        self.vstack.axis = .vertical
        self.hstack.addArrangedSubview(self.vstack)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.hstack.snp.makeConstraints { make in
            make.top.equalTo(
                self.titleVibrancyContainer.snp.bottom
            ).offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        self.circularProgressView.snp.makeConstraints { make in
            make.size.equalTo(circularProgressSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        if let weather = location.weather {
            self.weather = weather
            
            // remove all progress view.
            for subview in self.vstack.arrangedSubviews {
                subview.removeFromSuperview()
            }
            self.linearProgressViews.removeAll()
            
            // generate progress views.
            let aqi = weather.current.airQuality
            if let pm25 = aqi.pm25 {
                if pm25 > 0 {
                    self.linearProgressViews.append((
                        pm25 / 250.0,
                        getLevelColor(aqi.getPm25Level()),
                        self.generateLinearProgressView(
                            topDescription: "PM2.5",
                            bottomDescription: "\(Int(pm25))μg/m³"
                        )
                    ))
                }
            }
            if let pm10 = aqi.pm10 {
                if pm10 > 0 {
                    self.linearProgressViews.append((
                        pm10 / 420.0,
                        getLevelColor(aqi.getPm10Level()),
                        self.generateLinearProgressView(
                            topDescription: "PM10",
                            bottomDescription: "\(Int(pm10))μg/m³"
                        )
                    ))
                }
            }
            if let no2 = aqi.no2 {
                if no2 > 0 {
                    self.linearProgressViews.append((
                        no2 / 565.0,
                        getLevelColor(aqi.getNo2Level()),
                        self.generateLinearProgressView(
                            topDescription: "NO₂",
                            bottomDescription: "\(Int(no2))μg/m³"
                        )
                    ))
                }
            }
            if let so2 = aqi.so2 {
                if so2 > 0 {
                    self.linearProgressViews.append((
                        so2 / 1600.0,
                        getLevelColor(aqi.getSo2Level()),
                        self.generateLinearProgressView(
                            topDescription: "SO₂",
                            bottomDescription: "\(Int(so2))μg/m³"
                        )
                    ))
                }
            }
            if let o3 = aqi.o3 {
                if o3 > 0 {
                    self.linearProgressViews.append((
                        o3 / 800.0,
                        getLevelColor(aqi.getO3Level()),
                        self.generateLinearProgressView(
                            topDescription: "O₃",
                            bottomDescription: "\(Int(o3))μg/m³"
                        )
                    ))
                }
            }
            if let co = aqi.co {
                if co > 0 {
                    self.linearProgressViews.append((
                        co / 90.0,
                        getLevelColor(aqi.getCOLevel()),
                        self.generateLinearProgressView(
                            topDescription: "CO",
                            bottomDescription: "\(Int(co))mg/m³"
                        )
                    ))
                }
            }
            
            for progressView in self.linearProgressViews {
                self.vstack.addArrangedSubview(progressView.view)
                progressView.view.snp.makeConstraints { make in
                    make.height.equalTo(44.0)
                }
            }
        }
    }
    
    override func staggeredScrollIntoScreen(atFirstTime: Bool) {
        if atFirstTime {
            let aqiIndex = self.weather?.current.airQuality.aqiIndex ?? 0
            let aqiLevel = self.weather?.current.airQuality.aqiLevel ?? 0
            let aqiProgress = min(
                Double(aqiIndex) / Double(aqiIndexLevel5),
                1.0
            )
            self.circularProgressView.setProgress(
                aqiProgress,
                withAnimationDuration: 2.0 + 2.0 * aqiProgress,
                value: aqiIndex,
                andDescription: getAirQualityText(level: aqiLevel),
                betweenColors: (colorLevel1, getLevelColor(aqiLevel))
            )
            
            for progressView in self.linearProgressViews {
                progressView.view.setProgress(
                    progressView.progress,
                    withAnimationDuration: 2.0 + 2.0 + progressView.progress,
                    betweenColors: (colorLevel1, progressView.color)
                )
            }
        }
    }
    
    // MARK: - ui.
    
    private func generateLinearProgressView(
        topDescription: String,
        bottomDescription: String
    ) -> LinearProgressView {
        let view = LinearProgressView(frame: .zero)
        view.topDescription = topDescription
        view.bottomDiscription = bottomDescription
        return view
    }
}
