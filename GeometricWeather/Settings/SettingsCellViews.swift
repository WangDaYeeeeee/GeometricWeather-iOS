//
//  SettingsCellViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherBasic

// MARK: - toggle cell.

struct SettingsToggleCellView: View {
    
    let titleKey: String
    
    let toggleOn: Binding<Bool>
    
    var body: some View {
        Toggle(isOn: toggleOn) {
            SettingsTitleView(key: titleKey)
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
    
    let selectedIndex: Binding<Int>
        
    var body: some View {
        HStack {
            SettingsTitleView(key: titleKey)
            
            Spacer()
            
            Picker(
                getLocalizedText(self.keys[self.selectedIndex.wrappedValue]),
                selection: self.selectedIndex
            ) {
                ForEach(self.keys.indices) { index in
                    Text(
                        getLocalizedText(self.keys[index])
                    )
                }
            }.pickerStyle(
                .menu
            ).accentColor(
                Color(UIColor.systemBlue)
            )
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

// MARK: - time picker.

struct SettingsTimePickerCellView: View {
    
    let titleKey: String
    let enabled: Bool
    let selectedDate: Binding<Date>
    
    init(
        titleKey: String,
        enabled: Bool = true,
        selectedDate: Binding<Date>
    ) {
        self.titleKey = titleKey
        self.enabled = enabled
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        DatePicker(
            selection: self.selectedDate,
            displayedComponents: .hourAndMinute
        ) {
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
        }.padding(
            EdgeInsets(
                top: littleMargin / 2.0,
                leading: 0.0,
                bottom: littleMargin / 2.0,
                trailing: 0.0
            )
        ).opacity(
            self.enabled ? 1.0 : 0.5
        ).disabled(
            !self.enabled
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
                selectedIndex: .constant(0)
            )
            
            SettingsTimePickerCellView(
                titleKey: "settings_title_forecast_today_time",
                selectedDate: .constant(Date())
            )
        }
    }
}
