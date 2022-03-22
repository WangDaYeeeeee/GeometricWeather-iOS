//
//  AllergenViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/21.
//

import Foundation
import GeometricWeatherBasic

private let allergenReuseIdentifier = "allergen_trend_cell"
private let seperatorReuseIdentifier = "allergen_trend_seperator"
private let allergenCollectionViewHeight = 198

private let topInset = 56.0

class AllergenViewController: GeoViewController<Location>,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {
      
      // MARK: - properties.
      
      // subviews.
      
    private let blurBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .prominent)
    )
    private let titleContainer = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let divider = UIView(frame: .zero)
    
    private lazy var allergenCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .vertical
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
      
    // MARK: - life cycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        self.view.addSubview(self.blurBackground)

        self.allergenCollectionView.backgroundColor = .clear
        self.allergenCollectionView.showsVerticalScrollIndicator = false
        self.allergenCollectionView.showsHorizontalScrollIndicator = false
        self.allergenCollectionView.isPagingEnabled = false
        self.allergenCollectionView.dataSource = self
        self.allergenCollectionView.delegate = self
        self.allergenCollectionView.register(
            AllergenCollectionViewCell.self,
            forCellWithReuseIdentifier: allergenReuseIdentifier
        )
        self.allergenCollectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: seperatorReuseIdentifier
        )
        self.blurBackground.contentView.addSubview(self.allergenCollectionView)

        self.titleLabel.text = NSLocalizedString("allergen", comment: "")
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.titleContainer.addSubview(self.titleLabel)

        self.titleContainer.backgroundColor = .systemBackground
        self.blurBackground.contentView.addSubview(self.titleContainer)

        self.divider.backgroundColor = .separator
        self.blurBackground.contentView.addSubview(self.divider)

        self.blurBackground.snp.makeConstraints { make in
          make.size.equalToSuperview()
        }
        self.allergenCollectionView.snp.makeConstraints { make in
          make.top.equalToSuperview().offset(topInset)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          make.bottom.equalToSuperview()
        }
        self.titleContainer.snp.makeConstraints { make in
          make.top.equalToSuperview()
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          make.height.equalTo(topInset)
        }
        self.titleLabel.snp.makeConstraints { make in
          make.centerY.equalToSuperview()
          make.leading.equalToSuperview().offset(normalMargin)
          make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.divider.snp.makeConstraints { make in
          make.top.equalTo(self.titleContainer.snp.bottom)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          make.height.equalTo(0.5)
        }
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.row % 2 == 0 {
            return CGSize(
                width: Double(collectionView.frame.width),
                height: Double(allergenCollectionViewHeight)
            )
        } else {
            return CGSize(
                width: Double(collectionView.frame.width),
                height: 1.0
            )
        }
    }
    
    // data source.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 2 * (self.param.weather?.dailyForecasts.count ?? 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.row % 2 == 0 {
            let cell = self.allergenCollectionView.dequeueReusableCell(
                withReuseIdentifier: allergenReuseIdentifier,
                for: indexPath
            )
            if let weather = self.param.weather {
               (cell as? AllergenCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row / 2],
                    timezone: self.param.timezone,
                    index: indexPath.row / 2,
                    total: weather.dailyForecasts.count
               )
            }
            return cell
        }
        
        let cell = self.allergenCollectionView.dequeueReusableCell(
            withReuseIdentifier: seperatorReuseIdentifier,
            for: indexPath
        )
        cell.backgroundColor = .opaqueSeparator.withAlphaComponent(0.5)
        return cell
    }
}
