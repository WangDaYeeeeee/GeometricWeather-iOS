//
//  HomeViewController+Events.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import Foundation
import GeometricWeatherBasic

extension HomeViewController {
        
    func registerEventObservers() {
        
        // background updated.
        
        EventBus.shared.register(
            self,
            for: BackgroundUpdateEvent.self
        ) { [weak self] event in
            self?.vm.updateLocationFromBackground(
                location: event.location
            )
        }
        
        // settings changed.
        
        EventBus.shared.register(
            self,
            for: SettingsChangedEvent.self
        ) { [weak self] _ in
            self?.updateTableView()
        }
        
        // daily cell tapped.
        
        EventBus.shared.register(
            self,
            for: DailyTrendCellTapAction.self
        ) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.navigationController?.presentedViewController != nil {
                return
            }
                    
            strongSelf.navigationController?.present(
                DailyViewController(
                    param: (strongSelf.vm.currentLocation.value, event.index)
                ),
                animated: true,
                completion: nil
            )
        }
        
        // time bar tapped.
        
        EventBus.shared.register(
            self,
            for: TimeBarManagementAction.self
        ) { [weak self] _ in
            if self?.splitView ?? false {
                return
            }
            
            self?.onManagementButtonClicked()
        }
        
        // time bar alert tapped.
        
        EventBus.shared.register(
            self,
            for: TimeBarAlertAction.self
        ) { [weak self] _ in
            if self?.navigationController?.presentedViewController != nil {
                return
            }
            self?.navigationController?.present(
                AlertViewController(
                    param: self?.vm.currentLocation.value.weather?.alerts ?? []
                ),
                animated: true,
                completion: nil
            )
        }
        
        // edit button tapped.
        
        EventBus.shared.register(
            self,
            for: MainFooterEditButtonTapAction.self
        ) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.navigationController?.pushViewController(
                    strongSelf.editBuilder.editViewController,
                    animated: true
                )
            }
        }
        
        // opened from alert notification.
        
        EventBus.shared.stickyRegister(
            self,
            for: AlertNotificationAction.self
        ) { [weak self] event in
            guard
                let strongSelf = self,
                let _ = event
            else {
                return
            }
            
            strongSelf.vm.setLocation(index: 0)
            
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            
            if let presentedVC = strongSelf.navigationController?.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    strongSelf.navigationController?.present(
                        AlertViewController(
                            param: strongSelf.vm.currentLocation.value.weather?.alerts ?? []
                        ),
                        animated: true,
                        completion: nil
                    )
                }
                return
            }
            
            strongSelf.navigationController?.present(
                AlertViewController(
                    param: strongSelf.vm.currentLocation.value.weather?.alerts ?? []
                ),
                animated: true,
                completion: nil
            )
        }
        
        // opened from forecast notification.
        
        EventBus.shared.stickyRegister(
            self,
            for: ForecastNotificationAction.self
        ) { [weak self] event in
            guard
                let strongSelf = self,
                let _ = event
            else {
                return
            }
            
            strongSelf.vm.setLocation(index: 0)
            strongSelf.navigationController?.popToViewController(
                strongSelf,
                animated: true
            )
            strongSelf.navigationController?.presentedViewController?.dismiss(
                animated: true,
                completion: nil
            )
        }
        
        // opened from shortcut.
        
        EventBus.shared.stickyRegister(
            self,
            for: AppShortcutItemAction.self
        ) { [weak self] event in
            guard
                let strongSelf = self,
                let id = event?.formattedId
            else {
                return
            }
            
            strongSelf.vm.setLocation(formattedId: id)
            
            strongSelf.navigationController?.popToViewController(
                strongSelf,
                animated: true
            )
            strongSelf.navigationController?.presentedViewController?.dismiss(
                animated: true,
                completion: nil
            )
        }
    }
}
