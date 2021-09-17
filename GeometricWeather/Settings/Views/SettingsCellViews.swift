//
//  SettingsCellViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI

// MARK: - toggle cell.

struct SettingsToggleCellView: View {
    
    let titleKey: String
    
    let toggleOn: Binding<Bool>
    
    var body: some View {
        HStack {
            SettingsTitleView(key: titleKey)
            
            Spacer()
            
            Toggle("", isOn: toggleOn).labelsHidden()
        }.padding(
            EdgeInsets(
                top: littleMargin / 2.0,
                leading: 0.0,
                bottom: littleMargin / 2.0,
                trailing: 0.0
            )
        )
    }
}

// MARK: - list cell.

struct SettingsListCellView: View {
    
    let titleKey: String
    let keys: [String]
    
    let selectedKey: Binding<String>
    @State private var showActionSheet = false
    
    var body: some View {
        let key = self.keys.first { key in
            self.selectedKey.wrappedValue == key
        } ?? ""
        
        HStack {
            VStack(alignment: .leading) {
                SettingsTitleView(key: titleKey)
                SettingsCaptionView(key: key)
            }
            
            Spacer()
            
            Image(
                systemName: "chevron.forward"
            ).foregroundColor(
                Color(UIColor.label)
            )
        }.contentShape(
            Rectangle()
        ).onTapGesture {
            self.showActionSheet = true
        }.actionSheet(
            isPresented: self.$showActionSheet
        ) {
            return self.getActionSheet()
        }.padding(
            EdgeInsets(
                top: littleMargin / 2.0,
                leading: 0.0,
                bottom: littleMargin / 2.0,
                trailing: 0.0
            )
        )
    }
    
    private func getActionSheet() -> ActionSheet {
        let title = Text(
            NSLocalizedString(self.titleKey, comment: "")
        ).font(
            Font(largeTitleFont)
        )
        
        var buttons = self.keys.map { key in
            ActionSheet.Button.default(
                Text(
                    NSLocalizedString(key, comment: "")
                ).font(
                    Font(largeTitleFont)
                )
            ) {
                self.selectedKey.wrappedValue = key
            }
        }
        buttons.append(ActionSheet.Button.cancel {
            self.showActionSheet = false
        })
        
        return ActionSheet(
            title: title,
            message: nil,
            buttons: buttons
        )
    }
}

// MARK: - time picker.

struct SettingsTimePickerCellView: View {
    
    let titleKey: String
    
    let selectedDate: Binding<Date>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                SettingsTitleView(key: titleKey)
                
                Text(
                    formateTime(
                        timeIntervalSine1970:self.selectedDate.wrappedValue.timeIntervalSince1970,
                        twelveHour:isTwelveHour()
                    )
                ).font(
                    Font(captionFont)
                ).foregroundColor(
                    Color(UIColor.tertiaryLabel)
                )
            }
            
            Spacer()
            
            DatePicker(
                "",
                selection: self.selectedDate,
                displayedComponents: .hourAndMinute
            ).labelsHidden()
        }.padding(
            EdgeInsets(
                top: littleMargin / 2.0,
                leading: 0.0,
                bottom: littleMargin / 2.0,
                trailing: 0.0
            )
        )
    }
}

// MARK: - preview.

struct SettingsCellViews_Previews: PreviewProvider {
    
    static let toggleValue = true
    
    static var previews: some View {
        VStack {
            SettingsToggleCellView(
                titleKey: "settings_title_background_free",
                toggleOn: .constant(true)
            )
            
            SettingsListCellView(
                titleKey: "settings_title_weather_source",
                keys: [
                    "weather_source_cn",
                    "weather_source_caiyun",
                    "weather_source_accu",
                    "weather_source_owm",
                    "weather_source_mf",
                ],
                selectedKey: .constant("weather_source_cn")
            )
            
            SettingsTimePickerCellView(
                titleKey: "settings_title_forecast_today_time",
                selectedDate: .constant(Date())
            )
        }
    }
}
