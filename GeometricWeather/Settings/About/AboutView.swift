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
                    title: "Moya",
                    content: "You're a smart developer. You probably use Alamofire to abstract away access to URLSession and all those nasty details you don't really care about. But then, like lots of smart developers, you write ad hoc network abstraction layers. They are probably called \"APIManager\" or \"NetworkModel\", and they always end in tears."
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/Moya/Moya")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "SnapKit",
                    content: "SnapKit is a DSL to make Auto Layout easy on both iOS and OS X."
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/SnapKit/SnapKit")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "UICountingLabel",
                    content: "Adds animated counting support to UILabel."
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/dataxpress/UICountingLabel")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "Toast-Swift",
                    content: "Toast-Swift is a Swift extension that adds toast notifications to the UIView object class. It is intended to be simple, lightweight, and easy to use. Most toast notifications can be triggered with a single line of code."
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/scalessec/Toast-Swift")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
                
                ThanksItem(
                    title: "JXMovableCellTableView",
                    content: "The custom tableView which can start moving the cell with a long press gesture. The JXMovableCellTableView which added a UILongPressGestureRecognizer. when gesture started take a snapshot for cell which pressed.Then you can customize movable cell and start move animation."
                ).onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://github.com/pujiaxin33/JXMovableCellTableView")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
        }.listStyle(
            GroupedListStyle()
        )
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
