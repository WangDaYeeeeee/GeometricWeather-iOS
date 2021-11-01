//
//  MainViewController+Response.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import Foundation

extension MainViewController {
    
    func responseAlertNotificationAction() {
        self.viewModel.setLocation(index: 0)
        
        self.navigationController?.popToViewController(self, animated: true)
        
        if let presentedVC = self.navigationController?.presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.navigationController?.present(
                    AlertViewController(
                        param: self.viewModel.currentLocation.value.weather?.alerts ?? []
                    ),
                    animated: true,
                    completion: nil
                )
            }
            return
        }
        
        self.navigationController?.present(
            AlertViewController(
                param: self.viewModel.currentLocation.value.weather?.alerts ?? []
            ),
            animated: true,
            completion: nil
        )
    }
    
    func responseForecastNotificationAction() {
        self.viewModel.setLocation(index: 0)
        self.navigationController?.popToViewController(
            self,
            animated: true
        )
        self.navigationController?.presentedViewController?.dismiss(
            animated: true,
            completion: nil
        )
    }
    
    func responseAppShortcutItemAction(_ formattedId: String) {
        self.viewModel.setLocation(formattedId: formattedId)
        
        self.navigationController?.popToViewController(
            self,
            animated: true
        )
        self.navigationController?.presentedViewController?.dismiss(
            animated: true,
            completion: nil
        )
    }
    
    func responseDailyTrendCellTapAction(_ index: Int) {
        if self.navigationController?.presentedViewController != nil {
            return
        }
                
        self.navigationController?.present(
            DailyViewController(
                param: (self.viewModel.currentLocation.value, index)
            ),
            animated: true,
            completion: nil
        )
    }
    
    func responseToastMessage(_ message: MainToastMessage) {
        switch message {
        case .backgroundUpdate:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_updated_in_background", comment: "")
            )
            return
            
        case .locationFailed:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_location_failed", comment: "")
            )
            return
            
        case .weatherRequestFailed:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_get_weather_failed", comment: "")
            )
            return
        }
    }
}
