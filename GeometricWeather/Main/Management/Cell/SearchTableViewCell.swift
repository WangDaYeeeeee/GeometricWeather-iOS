//
//  SearchTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/3.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let normalBackgroundColor = UIColor.systemBackground
private let selectedBackgroundColor = UIColor.secondarySystemBackground

private let highlightAnimationDuration = 1.0
private let deHighlightAnimationDuration = 0.25

class SearchTableViewCell: UITableViewCell {
    
    static let cellHeight = 108.0
    
    // MARK: - subviews.
    
    private let highlightEffectContainer = UIView(frame: .zero)
    private let emptyLocationView = EmptyLocationItemView(frame: .zero)
    
    // MARK: - inner data.
    
    private var highlightAnimator: UIViewPropertyAnimator?
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.highlightEffectContainer)
        self.highlightEffectContainer.addSubview(self.emptyLocationView)
        
        self.highlightEffectContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.emptyLocationView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6.0)
            make.trailing.equalToSuperview().offset(-6.0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location, selected: Bool) {
        if (selected) {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = selectedBackgroundColor
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = normalBackgroundColor
            }
        }
        
        self.emptyLocationView.bindData(location: location)
    }
    
    // MARK: - selection.
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.highlightAnimator?.stopAnimation(false)
        self.highlightAnimator?.finishAnimation(at: .current)
        
        if !highlighted {
            self.highlightAnimator = UIViewPropertyAnimator(
                duration: deHighlightAnimationDuration,
                dampingRatio: 0.66
            ) {
                self.highlightEffectContainer.alpha = 1.0
                self.highlightEffectContainer.transform = .identity
            }
            self.highlightAnimator?.addCompletion { [weak self] position in
                if position == .end {
                    self?.highlightAnimator = nil
                }
            }
            self.highlightAnimator?.startAnimation()
            return
        }
        
        let a1 = UIViewPropertyAnimator(
            duration: highlightAnimationDuration * 0.33,
            controlPoint1: CGPoint(x: 0.2, y: 0.8),
            controlPoint2: CGPoint(x: 0.0, y: 1.0)
        ) {
            self.highlightEffectContainer.alpha = 0.5
            self.highlightEffectContainer.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
        a1.addCompletion { [weak self] position in
            if position == .end {
                self?.highlightAnimator = nil
            }
        }
        
        self.highlightAnimator = a1
        self.highlightAnimator?.startAnimation()
    }
}
