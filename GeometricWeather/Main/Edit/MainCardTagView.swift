//
//  MainCardTagView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI
import GeometricWeatherBasic

struct MainCardTagView: UIViewRepresentable {
    
    typealias UIViewType = CornerButton
    
    let title: String
    
    func makeUIView(context: Context) -> CornerButton {
        let button = CornerButton(frame: .zero, useLittleMargin: true)
        button.setTitle(self.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.shadowColor = button.backgroundColor?.cgColor
        button.layer.cornerRadius = 6.0
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
    func updateUIView(_ uiView: CornerButton, context: Context) {
        uiView.setTitle(self.title, for: .normal)
    }
}

struct MainCardTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainCardTagView(title: "Sun & Moon")
    }
}
