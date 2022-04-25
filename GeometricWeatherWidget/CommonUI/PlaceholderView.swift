//
//  PlaceholderView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/24.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        Image(
            uiImage: UIImage(namedInBasic: "launch_icon")!
                .scaleToSize(CGSize(width: 56.0, height: 56.0))!
        )
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
