//
//  MainSelectableTagView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/23.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let reuseId = "tag"

// MARK: - container.

protocol MainSelectableTagDelegate: NSObjectProtocol {
    
    func getSelectedColor() -> UIColor
    func getUnselectedColor() -> UIColor
    
    func onSelectedChanged(newSelectedIndex: Int)
}

class MainSelectableTagView: UICollectionView,
                                UICollectionViewDelegateFlowLayout,
                                UICollectionViewDataSource,
                                TagCellDelegate {
    
    // MARK: - inner data.
    
    var tagList = [String]() {
        didSet {
            self.reloadData()
            self.selectedIndex = 0
        }
    }
    private(set) var selectedIndex = 0 {
        didSet {
            if let cell = self.cellForItem(
                at: IndexPath(row: oldValue, section: 0)
            ) as? TagCell {
                cell.isSelectedCell = false
            }
            if let cell = self.cellForItem(
                at: IndexPath(row: self.selectedIndex, section: 0)
            ) as? TagCell {
                cell.isSelectedCell = true
            }
            
            self.tagDelegate?.onSelectedChanged(
                newSelectedIndex: self.selectedIndex
            )
        }
    }
    
    weak var tagDelegate: MainSelectableTagDelegate?
    
    // MARK: - life cycle.
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: littleMargin)
        
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.register(
            TagCell.self,
            forCellWithReuseIdentifier: reuseId
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - delegate.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.tagList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseId,
            for: indexPath
        ) as! TagCell
        
        cell.bindData(title: self.tagList.get(indexPath.row) ?? "", delegate: self)
        cell.isSelectedCell = self.selectedIndex == indexPath.row
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseId,
            for: indexPath
        ) as! TagCell
        
        cell.bindData(title: self.tagList.get(indexPath.row) ?? "", delegate: self)
        
        return cell.systemLayoutSizeFitting(.zero)
    }
    
    func getSelectedColor() -> UIColor {
        return self.tagDelegate?.getSelectedColor() ?? .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return self.tagDelegate?.getUnselectedColor() ?? .systemGray
    }
    
    func onSelectedChanged(cell: UICollectionViewCell) {
        if let indexPath = self.indexPath(for: cell) {
            self.selectedIndex = indexPath.row
        }
    }
}

// MARK: - cell.

private protocol TagCellDelegate: NSObjectProtocol {
    
    func getSelectedColor() -> UIColor
    func getUnselectedColor() -> UIColor
    
    func onSelectedChanged(cell: UICollectionViewCell)
}

private class TagCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let tagView = CornerButton(frame: .zero, useLittleMargin: true)
    
    var isSelectedCell: Bool = false {
        didSet {
            self.updateColors(selected: self.isSelectedCell)
        }
    }
    
    weak var delegate: TagCellDelegate?
    
    // MARK: - cell life cycles.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tagView.titleLabel?.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .semibold
        )
        self.tagView.addTarget(
            self,
            action: #selector(self.onTap),
            for: .touchUpInside
        )
        self.contentView.addSubview(self.tagView)
        
        self.tagView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(littleMargin)
            make.right.equalToSuperview()
        }
        
        ThemeManager.shared.daylight.addNonStickyObserver(
            self
        ) { [weak self] daylight in
            self?.updateColors(selected: self?.isSelectedCell ?? false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(title: String, delegate: TagCellDelegate) {
        self.delegate = delegate
        self.tagView.setTitle(title, for: .normal)
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.tagView.layer.shadowColor = self.tagView.backgroundColor?.cgColor
        }
    }
    
    private func updateColors(selected: Bool) {
        if selected {
            self.tagView.backgroundColor = self.delegate?.getSelectedColor() ?? .systemBlue
            self.tagView.setTitleColor(.white, for: .normal)
        } else {
            self.tagView.backgroundColor = self.delegate?.getUnselectedColor() ?? .systemYellow
            self.tagView.setTitleColor(.label, for: .normal)
        }
    }
    
    @objc private func onTap() {
        self.delegate?.onSelectedChanged(cell: self)
    }
}
