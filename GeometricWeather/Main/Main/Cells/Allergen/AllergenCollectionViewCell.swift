//
//  MainAllergenCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/22.
//

import UIKit

private let iconSize = 12.0

private let innerMargin = 12.0

class AllergenItemView: UIView {
    
    private let icon = UIImageView(frame: .zero)
    
    private let titleLabel = UILabel(frame: .zero)
    private let captionLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        self.icon.image = UIImage(systemName: "circle.fill")
        self.icon.contentMode = .scaleAspectFit
        self.addSubview(self.icon)
        
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.addSubview(self.titleLabel)
        
        self.captionLabel.font = miniCaptionFont
        self.captionLabel.textColor = .tertiaryLabel
        self.addSubview(self.captionLabel)
        
        self.icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.size.equalTo(iconSize)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.icon.snp.trailing).offset(innerMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalTo(self.icon.snp.centerY).offset(-1)
        }
        self.captionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.icon.snp.centerY).offset(1)
            make.leading.equalTo(self.icon.snp.trailing).offset(innerMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(color: UIColor, title: String, caption: String) {
        self.icon.tintColor = color
        self.titleLabel.text = title
        self.captionLabel.text = caption
    }
}

class AllergenCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel(frame: .zero)
    private let captionLabel = UILabel(frame: .zero)
    private let indicatorLabel = UILabel(frame: .zero)
    
    private let container = UIView(frame: .zero)
    private let grass = AllergenItemView(frame: .zero)
    private let mold = AllergenItemView(frame: .zero)
    private let ragweed = AllergenItemView(frame: .zero)
    private let tree = AllergenItemView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.addSubview(self.titleLabel)
        
        self.captionLabel.font = miniCaptionFont
        self.captionLabel.textColor = .tertiaryLabel
        self.addSubview(self.captionLabel)
        
        self.indicatorLabel.font = miniCaptionFont
        self.indicatorLabel.textColor = .tertiaryLabel
        self.addSubview(self.indicatorLabel)
        
        self.addSubview(self.container)
        
        self.container.addSubview(self.grass)
        self.container.addSubview(self.mold)
        self.container.addSubview(self.ragweed)
        self.container.addSubview(self.tree)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.captionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.indicatorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.container.snp.makeConstraints { make in
            make.top.equalTo(self.captionLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.grass.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.container.snp.centerX)
            make.bottom.equalTo(self.container.snp.centerY)
        }
        self.mold.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(self.container.snp.centerX)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.container.snp.centerY)
        }
        self.ragweed.snp.makeConstraints { make in
            make.top.equalTo(self.container.snp.centerY)
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.container.snp.centerX)
            make.bottom.equalToSuperview()
        }
        self.tree.snp.makeConstraints { make in
            make.top.equalTo(self.container.snp.centerY)
            make.leading.equalTo(self.container.snp.centerX)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(daily: Daily, timezone: TimeZone, index: Int, total: Int) {
        self.titleLabel.text = daily.getDate(
            format: NSLocalizedString("date_format_long", comment: "")
        )
        self.captionLabel.text = daily.isToday(timezone: timezone)
        ? NSLocalizedString("today", comment: "")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        self.indicatorLabel.text = (index + 1).description + "/" + total.description
        
        self.grass.bindData(
            color: getLevelColor(daily.pollen.grassLevel ?? 0),
            title: NSLocalizedString("grass", comment: ""),
            caption: (
                daily.pollen.grassIndex?.description ?? "0"
            ) + "/m³ - " + (
                daily.pollen.grassDescription ?? "?"
            )
        )
        self.mold.bindData(
            color: getLevelColor(daily.pollen.moldLevel ?? 0),
            title: NSLocalizedString("mold", comment: ""),
            caption: (
                daily.pollen.moldIndex?.description ?? "0"
            ) + "/m³ - " + (
                daily.pollen.moldDescription ?? "?"
            )
        )
        self.ragweed.bindData(
            color: getLevelColor(daily.pollen.ragweedLevel ?? 0),
            title: NSLocalizedString("ragweed", comment: ""),
            caption: (
                daily.pollen.ragweedIndex?.description ?? "0"
            ) + "/m³ - " + (
                daily.pollen.ragweedDescription ?? "?"
            )
        )
        self.tree.bindData(
            color: getLevelColor(daily.pollen.treeLevel ?? 0),
            title: NSLocalizedString("tree", comment: ""),
            caption: (
                daily.pollen.treeIndex?.description ?? "0"
            ) + "/m³ - " + (
                daily.pollen.treeDescription ?? "?"
            )
        )
    }
}
