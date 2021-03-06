//
//  MainAllergenCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/22.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let allergenReuseIdentifier = "allergen_trend_cell"
private let allergenCollectionViewHeight = 198

struct AllergenCollectionViewTapAction {}

class MainAllergenCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout {
    
    // MARK: - subviews.
        
    private lazy var allergenCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        return CollectionViewEffect(frame: .zero, collectionViewLayout: layout)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardTitle.text = getLocalizedText("allergen")
        
        self.allergenCollectionView.backgroundColor = .clear
        self.allergenCollectionView.showsVerticalScrollIndicator = false
        self.allergenCollectionView.showsHorizontalScrollIndicator = false
        self.allergenCollectionView.isPagingEnabled = true
        self.allergenCollectionView.dataSource = self
        self.allergenCollectionView.delegate = self
        self.allergenCollectionView.register(
            AllergenCollectionViewCell.self,
            forCellWithReuseIdentifier: allergenReuseIdentifier
        )
        self.allergenCollectionView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.onCollectionViewTapped)
            )
        )
        self.cardContainer.contentView.addSubview(self.allergenCollectionView)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.allergenCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.top).offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(allergenCollectionViewHeight)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        if self.allergenCollectionView.numberOfSections != 0
            && self.allergenCollectionView.numberOfItems(inSection: 0) != 0 {
            self.allergenCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .start,
                animated: false
            )
        }
        self.allergenCollectionView.collectionViewLayout.invalidateLayout()
        self.allergenCollectionView.reloadData()
    }
    
    @objc private func onDeviceOrientationChanged() {
        if let index = self.allergenCollectionView.indexPathsForVisibleItems.first {
            self.allergenCollectionView.scrollToItem(
                at: index,
                at: .start,
                animated: false
            )
            self.allergenCollectionView.reloadData()
        }
    }
    
    @objc private func onCollectionViewTapped() {
        self.window?.windowScene?.eventBus.post(AllergenCollectionViewTapAction())
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
    }
    
    // data source.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.location?.weather?.dailyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = self.allergenCollectionView.dequeueReusableCell(
            withReuseIdentifier: allergenReuseIdentifier,
            for: indexPath
        )
        if let weather = self.location?.weather {
           (cell as? AllergenCollectionViewCell)?.bindData(
                daily: weather.dailyForecasts[indexPath.row],
                timezone: self.location?.timezone ?? .current,
                index: indexPath.row,
                total: weather.dailyForecasts.count
           )
        }
        return cell
    }
}
