//
//  UILabelExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/29.
//

import UIKit

public extension UILabel {
    
    func setLeading(image: UIImage?, withText text: String?) {
        if let img = image {
            let attachment = NSTextAttachment()
            attachment.image = img
            attachment.bounds = CGRect(
                x: 0.0,
                y: (self.font.lineHeight - self.font.pointSize) / -2.0,
                width: self.font.pointSize,
                height: self.font.pointSize
            )

            let attachmentString = NSAttributedString(attachment: attachment)
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(attachmentString)
            
            let string = NSMutableAttributedString(
                string: " \(text ?? "")",
                attributes: [:]
            )
            mutableAttributedString.append(string)
            self.attributedText = mutableAttributedString
        } else {
            self.attributedText = NSAttributedString(string: text ?? "")
        }
    }
    
    func setTrailing(image: UIImage?, withText text: String?) {
        if let img = image {
            let attachment = NSTextAttachment()
            attachment.image = img
            attachment.bounds = CGRect(
                x: 0.0,
                y: (self.font.lineHeight - self.font.pointSize) / -2.0,
                width: self.font.pointSize,
                height: self.font.pointSize
            )

            let attachmentString = NSAttributedString(attachment: attachment)
            let string = NSMutableAttributedString(
                string: "\(text ?? "") ",
                attributes: [:]
            )

            string.append(attachmentString)
            self.attributedText = string
        } else {
            self.attributedText = NSAttributedString(string: text ?? "")
        }
    }
    
    func setLeadingImage(
        _ leadingImage: UIImage?,
        andTrailingImage trailingImage: UIImage?,
        withText text: String?
    ) {
        if let leadingImg = leadingImage,
            let trailingImg = trailingImage {
            
            let leading = NSTextAttachment()
            leading.image = leadingImg
            leading.bounds = CGRect(
                x: 0.0,
                y: (self.font.lineHeight - self.font.pointSize) / -2.0,
                width: self.font.pointSize,
                height: self.font.pointSize
            )
            
            let trailing = NSTextAttachment()
            trailing.image = trailingImg
            trailing.bounds = CGRect(
                x: 0.0,
                y: (self.font.lineHeight - self.font.pointSize) / -2.0,
                width: self.font.pointSize,
                height: self.font.pointSize
            )

            let leadingAS = NSAttributedString(attachment: leading)
            let trailingAS = NSAttributedString(attachment: trailing)
            
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(leadingAS)
            mutableAttributedString.append(
                NSMutableAttributedString(
                    string: " \(text ?? "") ",
                    attributes: [:]
                )
            )
            mutableAttributedString.append(trailingAS)
            self.attributedText = mutableAttributedString
        } else {
            self.attributedText = NSAttributedString(string: text ?? "")
        }
    }
}
