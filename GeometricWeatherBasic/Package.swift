// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeometricWeatherBasic",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        // .macOS(.v11),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GeometricWeatherBasic",
            targets: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
                "GeometricWeatherSettings",
                "GeometricWeatherTheme",
                "GeometricWeatherDB",
                "GeometricWeatherUpdate",
            ]
        ),
        .library(
            name: "GeometricWeatherWatchBasic",
            targets: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
                "GeometricWeatherTheme",
                "GeometricWeatherDB",
                "GeometricWeatherUpdate",
            ]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GeometricWeatherCore",
            dependencies: []
        ),
        .target(
            name: "GeometricWeatherResources",
            dependencies: [
                "GeometricWeatherCore",
            ]
        ),
        .target(
            name: "GeometricWeatherSettings",
            dependencies: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
            ]
        ),
        .target(
            name: "GeometricWeatherTheme",
            dependencies: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
            ]
        ),
        .target(
            name: "GeometricWeatherDB",
            dependencies: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
            ]
        ),
        .target(
            name: "GeometricWeatherUpdate",
            dependencies: [
                "GeometricWeatherCore",
                "GeometricWeatherResources",
                "GeometricWeatherDB",
                .product(name: "Moya", package: "Moya"),
                .product(name: "RxMoya", package: "Moya"),
                .product(name: "ReactiveMoya", package: "Moya"),
            ]
        ),
    ]
)
