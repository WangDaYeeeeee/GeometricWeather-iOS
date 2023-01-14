//
//  MainViewModel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class MainViewModel: NSObject {
    
    // state.
    let currentLocation: EqualtableLiveData<CurrentLocation>
    let indicator: EqualtableLiveData<Indicator>
    let selectableValidLocations: LiveData<SelectableLocationArray>
    let selectableTotalLocations: LiveData<SelectableLocationArray>
    let loading: EqualtableLiveData<Bool>
    let toastMessage: LiveData<MainToastMessage?>
    
    // inner data.
    private weak var scene: UIWindowScene?
    private var initCompleted: Bool
    
    // repository.
    private let repository = MainRepository()
    private var currentUpdateTask: Task<Void, Never>?
    
    // MARK: - life cycle.
    
    init(scene: UIWindowScene?) {
        self.scene = scene
        
        let data = repository.initLocations()
        
        // init inner data at first.
        self.initCompleted = false
        
        // init state properties.
        self.currentLocation = EqualtableLiveData(
            CurrentLocation(data.valid[0])
        )
        self.indicator = EqualtableLiveData(
            Indicator(total: data.valid.count, index: 0)
        )
        self.selectableValidLocations = LiveData(
            SelectableLocationArray(
                locations: data.valid,
                selectedId: data.valid[0].formattedId
            )
        )
        self.selectableTotalLocations = LiveData(
            SelectableLocationArray(
                locations: data.total,
                selectedId: data.valid[0].formattedId
            )
        )
        self.loading = EqualtableLiveData(false)
        
        self.toastMessage = LiveData(nil)
        
        super.init()
        
        // update theme.
        self.scene?.themeManager.update(location: data.valid[0])
        
        // register observer.
        EventBus.shared.register(
            self,
            for: LocationListUpdateEvent.self
        ) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            if event.scene == strongSelf.scene {
                return
            }
            
            strongSelf.cancelRequest()
            
            strongSelf.initCompleted = true
            strongSelf.loading.value = false
            strongSelf.updateInnerData(total: event.locations)
        }
                
        // read weather caches.
        Task(priority: .userInitiated) { [weak self] in
            let locations = await self?.repository.getWeatherCacheForLocations(
                oldList: data.total,
                ignoredFormattedId: [data.valid[0].formattedId]
            ) ?? data.total
            
            await MainActor.run { [weak self] in
                // received location list update event.
                // init already completed.
                if self?.initCompleted == true {
                    return
                }
                
                self?.initCompleted = true
                self?.updateInnerData(total: locations)
                
                updateAppExtensions(locations: locations, scene: self?.scene)
            }
        }
    }
    
    // MARK: - update inner data.
    
    private func updateInnerData(location: Location) {
        var total = self.selectableTotalLocations.value.locations
        
        for i in total.indices {
            if total[i].formattedId == location.formattedId {
                total[i] = location
                break
            }
        }
        
        self.updateInnerData(total: total)
    }
    
    private func updateInnerData(total: [Location]) {
        // get valid locations and current index.
        let valid = Location.excludeInvalidResidentLocation(
            locationArray: total
        )
        var index = 0
        for (i, item) in valid.enumerated() {
            if item.formattedId == self.selectableValidLocations.value.selectedId {
                index = i
                break
            }
        }
        
        self.indicator.value = Indicator(total: valid.count, index: index)
        
        // update current location.
        self.setCurrentLocationIfNecessary(location: valid[index])
        
        // check difference in valid locations.
        var diffInValidLocations = false
        
        if self.selectableValidLocations.value.locations.count != valid.count {
            diffInValidLocations = true
        } else {
            for i in 0 ..< self.selectableValidLocations.value.locations.count {
                if self.selectableValidLocations.value.locations[i] != valid[i] {
                    diffInValidLocations = true
                    break
                }
            }
        }
        
        if diffInValidLocations
            || self.selectableValidLocations.value.selectedId != valid[index].formattedId {
            self.selectableValidLocations.value = SelectableLocationArray(
                locations: valid,
                selectedId: valid[index].formattedId
            )
        }
        
        // update total locations.
        self.selectableTotalLocations.value = SelectableLocationArray(
            locations: total,
            selectedId: valid[index].formattedId
        )
    }
    
    private func setCurrentLocationIfNecessary(location: Location) {
        self.currentLocation.value = CurrentLocation(location)
        self.scene?.themeManager.update(location: location)
        
        self.checkToUpdateCurrentLocation()
    }
    
    private func checkToUpdateCurrentLocation() {
        // only need to update current location after init completed.
        if !self.initCompleted {
            self.loading.value = true
            return
        }
        
        // is loading, do nothing.
        if self.loading.value {
            return
        }
        
        // if already valid, just return.
        if self.currentLocationIsValid() {
            return
        }
        
        // if is not valid, we need update current location.
        self.updateCurrentLocationWithChecking()
    }
    
    private func currentLocationIsValid() -> Bool {
        return currentLocation.value.location.weather?.isValid(
            pollingIntervalHours: SettingsManager.shared.updateInterval.hours
        ) ?? false
    }
    
    // MARK: - update.
    
    func updateCurrentLocationWithChecking() {
        if self.loading.value {
            return
        }
        
        self.loading.value = true
        
        let location = self.currentLocation.value.location
        
        self.currentUpdateTask = Task(priority: .background) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let result = await withTaskCancellationHandler {
                await strongSelf.repository.update(location: location)
            } onCancel: {
                strongSelf.repository.cancelUpdate()
            }
            
            await MainActor.run {
                if Task.isCancelled {
                    return
                }
                
                if !result.weatherRequestSucceed {
                    strongSelf.toastMessage.value = .weatherRequestFailed
                } else if result.locationSucceed == false {
                    strongSelf.toastMessage.value = .locationFailed
                }
                
                strongSelf.updateInnerData(location: result.location)
                
                strongSelf.loading.value = false
                
                printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
                updateAppExtensions(
                    locations: strongSelf.selectableTotalLocations.value.locations,
                    scene: strongSelf.scene
                )
            }
        }
    }
    
    func cancelRequest() {
        self.loading.value = false
        
        self.currentUpdateTask?.cancel()
        self.currentUpdateTask = nil
    }
    
    func checkToUpdate() {
        cancelRequest()
        
        self.currentLocation.value = CurrentLocation(self.currentLocation.value.location)
        self.scene?.themeManager.update(location: self.currentLocation.value.location)
        
        let total = self.selectableTotalLocations.value.locations
        self.initCompleted = false
        self.loading.value = true
        
        Task(priority: .userInitiated) { [weak self] in
            let locations = await self?.repository.getWeatherCacheForLocations(
                oldList: total,
                ignoredFormattedId: []
            ) ?? total
            
            await MainActor.run { [weak self] in
                // received location list update event.
                // init already completed.
                if self?.initCompleted == true {
                    return
                }
                
                self?.initCompleted = true
                self?.loading.value = false
                self?.updateInnerData(total: locations)
                
                updateAppExtensions(locations: locations, scene: self?.scene)
            }
        }
    }
    
    func updateLocationFromBackground(
        location: Location
    ) {
        if !initCompleted {
            return
        }
        
        if self.currentLocation.value.location.formattedId == location.formattedId {
            if self.loading.value {
                self.toastMessage.value = .backgroundUpdate
            }
            self.cancelRequest()
        }
        self.updateInnerData(location: location)
    }
    
    // MARK: - set location.
    
    func setLocation(index: Int) {
        let location = self.selectableValidLocations.value.locations[index]
        self.setLocation(formattedId: location.formattedId)
    }
    
    func setLocation(formattedId: String) {
        self.cancelRequest()
        
        let index = self.selectableValidLocations.value.locations.firstIndex { item in
            item.formattedId == formattedId
        } ?? 0
        let location = self.selectableValidLocations.value.locations[index]
        
        self.setCurrentLocationIfNecessary(location: location)
        
        self.indicator.value = Indicator(
            total: self.selectableValidLocations.value.locations.count,
            index: index
        )
        
        self.selectableTotalLocations.value = SelectableLocationArray(
            locations: self.selectableTotalLocations.value.locations,
            selectedId: location.formattedId
        )
        self.selectableValidLocations.value = SelectableLocationArray(
            locations: self.selectableValidLocations.value.locations,
            selectedId: location.formattedId
        )
    }
    
    // return true if current location changed.
    func offsetLocation(offset: Int) -> Bool {
        self.cancelRequest()
        
        let oldFormattedId = self.currentLocation.value.location.formattedId
        
        // ensure current index.
        var index = 0
        for (i, location) in self.selectableValidLocations.value.locations.enumerated() {
            if location.formattedId == self.currentLocation.value.location.formattedId {
                index = i
                break
            }
        }
        
        // update index.
        index = (
            index + offset + self.selectableValidLocations.value.locations.count
        ) % self.selectableValidLocations.value.locations.count
        
        // update location.
        self.setCurrentLocationIfNecessary(
            location: self.selectableValidLocations.value.locations[index]
        )
        
        self.indicator.value = Indicator(
            total: self.selectableValidLocations.value.locations.count,
            index: index
        )
        
        self.selectableTotalLocations.value = SelectableLocationArray(
            locations: self.selectableTotalLocations.value.locations,
            selectedId: self.currentLocation.value.location.formattedId
        )
        self.selectableValidLocations.value = SelectableLocationArray(
            locations: self.selectableValidLocations.value.locations,
            selectedId: self.currentLocation.value.location.formattedId
        )
        
        return self.currentLocation.value.location.formattedId != oldFormattedId
    }
    
    // MARK: - list.
    
    // return false if failed.
    func addLocation(
        location: Location,
        index: Int? = nil
    ) -> Bool {
        // do not add an existed location.
        for item in self.selectableTotalLocations.value.locations {
            if item.formattedId == location.formattedId {
                return false
            }
        }
                
        var total = self.selectableTotalLocations.value.locations
        total.insert(
            location,
            at: index ?? self.selectableTotalLocations.value.locations.count
        )
        
        self.updateInnerData(total: total)
        Task(priority: .background) { [total] in
            await self.repository.writeLocations(locations: total)
        }
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions(locations: total, scene: self.scene)
        
        return true
    }
    
    func moveLocation(from: Int, to: Int) {
        if from == to {
            return
        }
        
        var total = self.selectableTotalLocations.value.locations
        
        total.insert(total.remove(at: from), at: to)
                
        self.updateInnerData(total: total)
        Task(priority: .background) { [total] in
            await self.repository.writeLocations(locations: total)
        }
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions(locations: total, scene: self.scene)
    }
    
    func updateLocation(location: Location) {
        self.updateInnerData(location: location)
        
        let total = self.selectableTotalLocations.value.locations
        Task(priority: .background) {
            await self.repository.writeLocations(locations: total)
        }
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions(locations: total, scene: self.scene)
    }
    
    func deleteLocation(position: Int) {
        var total = self.selectableTotalLocations.value.locations
        let location = total.remove(at: position)
        
        self.updateInnerData(total: total)
        Task(priority: .background) {
            await self.repository.deleteLocation(location: location)
        }
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions(locations: total, scene: self.scene)
    }
    
    // MARK: - getter.
    
    func getValidLocation(offset: Int) -> Location {
        // ensure current index.
        var index = 0
        for (
            i, location
        ) in self.selectableValidLocations.value.locations.enumerated() {
            if location.formattedId == self.currentLocation.value.location.formattedId {
                index = i
                break
            }
        }
        
        // update index.
        index = (
            index + offset + self.selectableValidLocations.value.locations.count
        ) % self.selectableValidLocations.value.locations.count
        
        return self.selectableValidLocations.value.locations[index]
    }
}
