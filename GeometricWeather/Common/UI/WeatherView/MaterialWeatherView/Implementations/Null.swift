//
//  Null.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/18.
//

import SwiftUI

struct NullForegroundView: View {
    
    var body: some View {
        Group {
            // draw nothing.
        }
    }
}

struct NullBackgroundView: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, .clear]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Null_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            NullForegroundView()
        }.background(
            NullBackgroundView()
        ).ignoresSafeArea()
    }
}
