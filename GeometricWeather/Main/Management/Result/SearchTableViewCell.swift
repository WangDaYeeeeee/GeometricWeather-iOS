//
//  SearchTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/3.
//

import UIKit
import GeometricWeatherBasic

private let iconSize = 24.0

private let normalBackgroundColor = UIColor.systemBackground
private let selectedBackgroundColor = UIColor.secondarySystemBackground

private let highlightAnimationDuration = 1.0
private let deHighlightAnimationDuration = 0.25

class SearchTableViewCell: UITableViewCell {
    
    static let cell = 96.0
    
    // MARK: - subviews.
    
    private let highlightEffectContainer = UIView(frame: .zero)
    
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    
    private let weatherSourceLabel = UILabel(frame: .zero)
    
    // MARK: - inner data.
    
    private var highlightAnimator: UIViewPropertyAnimator?
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.highlightEffectContainer)
        
        self.titleLabel.textColor = .label
        self.titleLabel.font = largeTitleFont
        self.highlightEffectContainer.addSubview(self.titleLabel)
        
        self.subtitleLabel.textColor = .tertiaryLabel
        self.subtitleLabel.font = miniCaptionFont
        self.highlightEffectContainer.addSubview(self.subtitleLabel)
        
        self.weatherSourceLabel.textColor = .tertiaryLabel
        self.weatherSourceLabel.font = UIFont.systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        self.highlightEffectContainer.addSubview(self.weatherSourceLabel)
        
        self.highlightEffectContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.weatherSourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
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
        
        self.titleLabel.text = location.currentPosition
        ? NSLocalizedString("current_location", comment: "")
        : getLocationText(location: location)
        
        if location.residentPosition && location.weather != nil {
            self.titleLabel.setLeadingImage(
                UIImage(
                    systemName: "checkmark.seal.fill"
                )?.withTintColor(
                    .systemBlue
                ),
                andTrailingImage: .getWeatherIcon(
                    weatherCode: location.weather?.current.weatherCode ?? .clear,
                    daylight: location.daylight
                ),
                withText: self.titleLabel.text
            )
        } else if location.weather != nil {
            self.titleLabel.setTrailing(
                image: .getWeatherIcon(
                    weatherCode: location.weather?.current.weatherCode ?? .clear,
                    daylight: location.daylight
                ),
                withText: self.titleLabel.text
            )
        } else if location.residentPosition {
            self.titleLabel.setLeading(
                image: UIImage(
                    systemName: "checkmark.seal.fill"
                )?.withTintColor(
                    .systemBlue
                ),
                withText: self.titleLabel.text
            )
        } else {
            self.titleLabel.setLeading(
                image: nil,
                withText: self.titleLabel.text
            )
        }
        
        self.subtitleLabel.text = location.toString()
        
        self.weatherSourceLabel.text = "Powered by \(location.weatherSource.url)"
        self.weatherSourceLabel.textColor = .colorFromRGB(location.weatherSource.color)
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
