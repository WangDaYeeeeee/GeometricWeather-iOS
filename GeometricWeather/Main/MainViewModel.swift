//
//  MainViewModel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherBasic

class MainViewModel: NSObject, UIStateRestoring {
    
    // state.
    let currentLocation: EqualtableLiveData<Location>
    let indicator: EqualtableLiveData<Indicator>
    let selectableValidLocations: LiveData<SelectableLocationArray>
    let selectableTotalLocations: LiveData<SelectableLocationArray>
    let loading: EqualtableLiveData<Bool>
    let toastMessage: LiveData<MainToastMessage?>
    
    // inner data.
    private var initCompleted: Bool
    private var pendingReloadDBCacheIdSet = Set<String>()
    
    // repository.
    private let repository = MainRepository()
    
    // MARK: - life cycle.
    
    override init() {
        let data = repository.initLocations()
        
        // init inner data at first.
        self.initCompleted = false
        
        // init state properties.
        self.currentLocation = EqualtableLiveData(data.valid[0])
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
        ThemeManager.shared.update(location: data.valid[0])
                
        // read weather caches.
        self.repository.getWeatherCacheForLocations(
            oldList: data.total,
            ignoredFormattedId: data.valid[0].formattedId
        ) { [weak self] locations in
            self?.initCompleted = true
            self?.updateInnerData(total: locations)
        }
    }
    
    deinit {
        self.cancelRequest()
    }
    
    func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.currentLocation.value.formattedId, forKey: "formattedId")
    }
    
    func decodeRestorableState(with coder: NSCoder) {
        if let id = coder.decodeObject(forKey: "formattedId") as? String {
            self.setLocation(formattedId: id)
        }
    }
    
    // MARK: - update inner data.
    
    private func updateInnerData(location: Location) {
        var total = self.selectableTotalLocations.value.locations
        
        for i in 0 ..< total.count {
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
        self.setCurrentLocation(location: valid[index])
        
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
    
    private func setCurrentLocation(
        location: Location
    ) {
        if self.currentLocation.value != location {
            self.currentLocation.value = location
        }
        ThemeManager.shared.update(location: self.currentLocation.value)
        
        self.checkToUpdateCurrentLocation()
    }
    
    private func onUpdateResult(
        location: Location,
        locationResult: Bool?,
        weatherUpdateResult: Bool
    ) {
        if !weatherUpdateResult {
            self.toastMessage.value = .weatherRequestFailed
        } else if !(locationResult ?? true) {
            self.toastMessage.value = .locationFailed
        }
        
        self.updateInnerData(location: location)
        
        self.loading.value = false
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions()
    }
    
    private func checkToUpdateCurrentLocation() {
        // if the pending reload db cache id set contains this location's formatted id
        // we need to read cache data from database.
        let sholdCheckNewDBCache = self.pendingReloadDBCacheIdSet.contains(
            self.currentLocation.value.formattedId
        )
        
        // if the app is completed init progress and is not updating data,
        // and it should check cache from db.
        //
        // then, read db.
        if sholdCheckNewDBCache
            && !self.loading.value
            && self.initCompleted {
                        
            self.loading.value = true
            // read new cache from database.
            self.repository.getWeatherCacheForLocations(
                oldList: [self.currentLocation.value],
                ignoredFormattedId: ""
            ) { [weak self] result in
                guard let newLocation = result.first else {
                    return
                }
                self?.pendingReloadDBCacheIdSet.remove(newLocation.formattedId)
                
                self?.loading.value = false
                self?.updateInnerData(location: newLocation)
            }
            return
        }
        
        // if should read db cache, but the app is updating or just in an init progress.
        //
        // then, we need delete the flag.
        if sholdCheckNewDBCache {
            self.pendingReloadDBCacheIdSet.remove(self.currentLocation.value.formattedId)
        }
        
        // is not loading
        if !self.loading.value {
            // if already valid, just return.
            if self.currentLocationIsValid() {
                return
            }
            
            // if is not valid, we need:
            // update if init completed.
            // otherwise, mark a loading state and wait the init progress complete.
            if self.initCompleted {
                self.updateWithUpdatingChecking()
            } else {
                self.loading.value = true
            }
            return
        }
        
        // is loading, do nothing.
    }
    
    private func currentLocationIsValid() -> Bool {
        return currentLocation.value.weather?.isValid(
            pollingIntervalHours: SettingsManager.shared.updateInterval.hours
        ) ?? false
    }
    
    // MARK: - update.
    
    func updateWithUpdatingChecking() {
        if self.loading.value {
            return
        }
        
        self.loading.value = true
        
        self.repository.update(
            location: self.currentLocation.value,
            callback: self.onUpdateResult
        )
    }
    
    func cancelRequest() {
        self.loading.value = false
        self.repository.cancel()
    }
    
    func checkToUpdate() {
        ThemeManager.shared.update(location: currentLocation.value)
        
        self.pendingReloadDBCacheIdSet.removeAll()
        self.selectableTotalLocations.value.locations.forEach { location in
            self.pendingReloadDBCacheIdSet.insert(location.formattedId)
        }
        
        self.checkToUpdateCurrentLocation()
    }
    
    func updateLocationFromBackground(
        location: Location
    ) {
        if !initCompleted {
            return
        }
        
        if self.currentLocation.value.formattedId == location.formattedId {
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
        
        for (i, location) in self.selectableValidLocations.value.locations.enumerated() {
            if location.formattedId != formattedId {
                continue
            }
            
            self.setCurrentLocation(location: location)
            
            self.indicator.value = Indicator(
                total: self.selectableValidLocations.value.locations.count,
                index: i
            )
            
            self.selectableTotalLocations.value = SelectableLocationArray(
                locations: self.selectableTotalLocations.value.locations,
                selectedId: formattedId
            )
            self.selectableValidLocations.value = SelectableLocationArray(
                locations: self.selectableValidLocations.value.locations,
                selectedId: formattedId
            )
            break
        }
    }
    
    // return true if current location changed.
    func offsetLocation(offset: Int) -> Bool {
        self.cancelRequest()
        
        let oldFormattedId = self.currentLocation.value.formattedId
        
        // ensure current index.
        var index = 0
        for (i, location) in self.selectableValidLocations.value.locations.enumerated() {
            if location.formattedId == self.currentLocation.value.formattedId {
                index = i
                break
            }
        }
        
        // update index.
        index = (
            index + offset + self.selectableValidLocations.value.locations.count
        ) % self.selectableValidLocations.value.locations.count
        
        // update location.
        self.setCurrentLocation(
            location: self.selectableValidLocations.value.locations[index]
        )
        
        self.indicator.value = Indicator(
            total: self.selectableValidLocations.value.locations.count,
            index: index
        )
        
        self.selectableTotalLocations.value = SelectableLocationArray(
            locations: self.selectableTotalLocations.value.locations,
            selectedId: self.currentLocation.value.formattedId
        )
        self.selectableValidLocations.value = SelectableLocationArray(
            locations: self.selectableValidLocations.value.locations,
            selectedId: self.currentLocation.value.formattedId
        )
        
        return self.currentLocation.value.formattedId != oldFormattedId
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
        self.repository.writeLocations(locations: total)
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions()
        
        return true
    }
    
    func moveLocation(from: Int, to: Int) {
        if from == to {
            return
        }
        
        var total = self.selectableTotalLocations.value.locations
        
        total.insert(total.remove(at: from), at: to)
                
        self.updateInnerData(total: total)
        self.repository.writeLocations(locations: total)
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions()
    }
    
    func updateLocation(location: Location) {
        self.updateInnerData(location: location)
        self.repository.writeLocations(
            locations: self.selectableTotalLocations.value.locations
        )
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions()
    }
    
    func deleteLocation(position: Int) {
        var total = self.selectableTotalLocations.value.locations
        let location = total.remove(at: position)
        
        self.updateInnerData(total: total)
        self.repository.deleteLocation(location: location)
        
        printLog(keyword: "widget", content: "update app extensions cause updated in main interface")
        updateAppExtensions()
    }
    
    // MARK: - getter.
    
    func getValidLocation(offset: Int) -> Location {
        // ensure current index.
        var index = 0
        for (
            i, location
        ) in self.selectableValidLocations.value.locations.enumerated() {
            if location.formattedId == self.currentLocation.value.formattedId {
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
