//
//  HomeViewController+Events.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

extension HomeViewController {
    
    func registerEventObservers() {
        
        // MARK: - background updated.
        
        EventBus.shared.register(
            self,
            for: BackgroundUpdateEvent.self
        ) { [weak self] event in
            self?.vm.updateLocationFromBackground(
                location: event.location
            )
        }
        
        // MARK: - settings changed.
        
        EventBus.shared.register(
            self,
            for: SettingsChangedEvent.self
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.updateTableView()
            self.vm.updateAppExtensions()
        }
        
        // MARK: - scene enter foreground.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
            self,
            for: SceneEnterForegroundEvent.self
        ) { [weak self] event in
            self?.vm.checkToUpdate()
        }
        
        // MARK: - daily cell tapped.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
            self,
            for: DailyTrendCellTapAction.self
        ) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
                    
            strongSelf.navigationController?.pushViewController(
                DailyViewController(
                    param: (strongSelf.vm.currentLocation.value.location, event.index),
                    in: strongSelf.navigationController?.view.window?.windowScene
                ),
                animated: true
            )
        }
        
        // MARK: - hourly cell tapped.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
            self,
            for: HourlyTrendCellTapAction.self
        ) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
                    
            strongSelf.navigationController?.pushViewController(
                HourlyViewController(
                    param: (strongSelf.vm.currentLocation.value.location, event.index),
                    in: strongSelf.navigationController?.view.window?.windowScene
                ),
                animated: true
            )
        }
        
        // MARK: - time bar alert tapped.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
            self,
            for: TimeBarAlertAction.self
        ) { [weak self] _ in
            if self?.navigationController?.presentedViewController != nil {
                return
            }
            self?.navigationController?.present(
                AlertViewController(
                    param: self?.vm.currentLocation.value.location.weather?.alerts ?? [],
                    in: self?.navigationController?.view.window?.windowScene
                ),
                animated: true,
                completion: nil
            )
        }
        
        // MARK: - allergen collection view tapped.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
            self,
            for: AllergenCollectionViewTapAction.self
        ) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.navigationController?.presentedViewController != nil {
                return
            }
            strongSelf.navigationController?.present(
                AllergenViewController(
                    param: strongSelf.vm.currentLocation.value.location,
                    in: strongSelf.navigationController?.view.window?.windowScene
                ),
                animated: true,
                completion: nil
            )
        }
        
        // MARK: - edit button tapped.
        
        self.navigationController?.view.window?.windowScene?.eventBus.register(
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
        
        // MARK: - opened from alert notification.
        
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
                            param: strongSelf.vm.currentLocation.value.location.weather?.alerts ?? [],
                            in: strongSelf.navigationController?.view.window?.windowScene
                        ),
                        animated: true,
                        completion: nil
                    )
                }
                return
            }
            
            strongSelf.navigationController?.present(
                AlertViewController(
                    param: strongSelf.vm.currentLocation.value.location.weather?.alerts ?? [],
                    in: strongSelf.navigationController?.view.window?.windowScene
                ),
                animated: true,
                completion: nil
            )
        }
        
        // MARK: - opened from forecast notification.
        
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
        
        // MARK: - opened from shortcut.
        
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
