//
//  MainCardTagView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct MainCardTagView: UIViewRepresentable {
    
    typealias UIViewType = CornerButton
    
    let title: String
    
    func makeUIView(context: Context) -> CornerButton {
        let button = CornerButton(frame: .zero, useLittleMargin: true)
        button.setTitle(self.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .semibold
        )
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
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
