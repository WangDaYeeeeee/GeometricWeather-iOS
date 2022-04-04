

import Foundation
import GeometricWeatherBasic
import NeedleFoundation

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->MainComponent->EditComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->MainComponent->SettingsComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->MainComponent->HomeComponent") { component in
        return HomeDependency887e91671f4424758155Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->MainComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->MainComponent->ManagementConponent") { component in
        return ManagementDependency04a6d2d9dc503e8de2a1Provider(component: component)
    }
    
}

// MARK: - Providers

private class HomeDependency887e91671f4424758155BaseProvider: HomeDependency {
    var mainViewModel: MainViewModel {
        return mainComponent.mainViewModel
    }
    var managementComponent: ManagementConponent {
        return mainComponent.managementComponent
    }
    var editComponent: EditComponent {
        return mainComponent.editComponent
    }
    var settingsComponent: SettingsComponent {
        return mainComponent.settingsComponent
    }
    private let mainComponent: MainComponent
    init(mainComponent: MainComponent) {
        self.mainComponent = mainComponent
    }
}
/// ^->MainComponent->HomeComponent
private class HomeDependency887e91671f4424758155Provider: HomeDependency887e91671f4424758155BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(mainComponent: component.parent as! MainComponent)
    }
}
private class ManagementDependency04a6d2d9dc503e8de2a1BaseProvider: ManagementDependency {
    var mainViewModel: MainViewModel {
        return mainComponent.mainViewModel
    }
    private let mainComponent: MainComponent
    init(mainComponent: MainComponent) {
        self.mainComponent = mainComponent
    }
}
/// ^->MainComponent->ManagementConponent
private class ManagementDependency04a6d2d9dc503e8de2a1Provider: ManagementDependency04a6d2d9dc503e8de2a1BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(mainComponent: component.parent as! MainComponent)
    }
}
