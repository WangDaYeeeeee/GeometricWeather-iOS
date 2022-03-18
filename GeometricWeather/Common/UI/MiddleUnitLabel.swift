//
//  MiddleUnitLabel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/17.
//

import Foundation

private func stringStartWithSign(_ string: String) -> Bool {
    return string.starts(with: "-")
    || string.starts(with: "<")
}

class MiddleUnitLabel: UIView {
    
    private let signLabel = UILabel(frame: .zero)
    private let numberLabel = UILabel(frame: .zero)
    private let unitLabel = UILabel(frame: .zero)
    
    override var intrinsicContentSize: CGSize {
        let signSize = self.signLabel.intrinsicContentSize
        let numberSize = self.numberLabel.intrinsicContentSize
        let unitSize = self.unitLabel.intrinsicContentSize
        
        return CGSize(
            width: numberSize.width + 2 * max(signSize.width, unitSize.width),
            height: numberSize.height
        )
    }
    
    var text: (value: String, unit: String)? {
        didSet {
            if let newValue = self.text {
                self.signLabel.text = stringStartWithSign(newValue.value)
                ? String(newValue.value.first ?? Character(""))
                : ""
                self.numberLabel.text = stringStartWithSign(newValue.value)
                ? String(newValue.value.dropFirst())
                : newValue.value
                self.unitLabel.text = newValue.unit
            } else {
                self.signLabel.text = ""
                self.numberLabel.text = ""
                self.unitLabel.text = ""
            }
            
            self.invalidateIntrinsicContentSize()
        }
    }
    var font: UIFont? {
        didSet {
            self.signLabel.font = self.font
            self.numberLabel.font = self.font
            self.unitLabel.font = self.font
            
            self.invalidateIntrinsicContentSize()
        }
    }
    var textColor: UIColor? {
        didSet {
            self.signLabel.textColor = self.textColor
            self.numberLabel.textColor = self.textColor
            self.unitLabel.textColor = self.textColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.signLabel)
        self.addSubview(self.numberLabel)
        self.addSubview(self.unitLabel)
        
        self.numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.signLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.numberLabel.snp.leading)
        }
        self.unitLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.numberLabel.snp.trailing)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeToFit() {
        self.frame = CGRect(origin: self.frame.origin, size: self.intrinsicContentSize)
    }
}
