//
//  MainViewController+Response.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import Foundation

extension MainViewController {
    
    @objc func responseAlertNotificationAction() {
        self.viewModel.setLocation(index: 0)
        self.alertViewController.alertList = self.viewModel.currentLocation.value.weather?.alerts ?? []
        
        self.navigationController?.popToViewController(self, animated: true)
        
        if let presentedVC = self.navigationController?.presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.navigationController?.present(
                    self.alertViewController,
                    animated: true,
                    completion: nil
                )
            }
            return
        }
        
        self.navigationController?.present(
            self.alertViewController,
            animated: true,
            completion: nil
        )
    }
    
    @objc func responseForecastNotificationAction() {
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
    
    @objc func responseAppShortcutItemAction(_ notification: NSNotification) {
        if let formattedId = (notification.object as? String) {
            self.viewModel.setLocation(formattedId: formattedId)
        }
        self.navigationController?.popToViewController(
            self,
            animated: true
        )
        self.navigationController?.presentedViewController?.dismiss(
            animated: true,
            completion: nil
        )
    }
    
    @objc func responseDailyTrendCellTapAction(_ notification: NSNotification) {
        if self.navigationController?.presentedViewController != nil {
            return
        }
        guard let index = (notification.object as? Int) else {
            return
        }
        
        let vc = DailyViewController(nibName: nil, bundle: nil)
        vc.initData = (self.viewModel.currentLocation.value, index)
        
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
