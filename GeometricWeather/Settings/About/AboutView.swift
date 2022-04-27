//
//  AboutView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        List {
            AboutHeader()
            
            Section(
                header: AboutSectionTitle(key: "about_app")
            ) {
                AboutAppItem(
                    icon: "filemenu.and.selection",
                    key: "gitHub"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/WangDaYeeeeee/GeometricWeather-iOS")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                AboutAppItem(
                    icon: "envelope",
                    key: "email"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "mailto:wangdayeeeeee@gmail.com")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
            
            Section(
                header: AboutSectionTitle(key: "thanks")
            ) {
                ThanksItem(
                    title: "Moya"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/Moya/Moya")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "SnapKit"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/SnapKit/SnapKit")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "UICountingLabel"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/dataxpress/UICountingLabel")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "Toast-Swift"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/scalessec/Toast-Swift")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "JXMovableCellTableView"
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/pujiaxin33/JXMovableCellTableView")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
        }.listStyle(
            .insetGrouped
        )
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
