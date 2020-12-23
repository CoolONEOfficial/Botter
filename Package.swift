// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Botter",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Botter",
            targets: ["Botter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.9.0"),
        .package(url: "https://github.com/givip/Telegrammer.git", .branch("develop")),
        .package(url: "https://github.com/givip/telegrammer-vapor-middleware.git", .branch("develop")),
        .package(path: "./Vkontakter"),
        .package(path: "./vkontakter-vapor-middleware")
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Botter",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Telegrammer", package: "Telegrammer"),
                .product(name: "Vkontakter", package: "Vkontakter"),
                .product(name: "TelegrammerMiddleware", package: "telegrammer-vapor-middleware"),
                .product(name: "VkontakterMiddleware", package: "vkontakter-vapor-middleware")
                .product(name: "AnyCodable", package: "AnyCodable"),
            ]),
        .testTarget(
            name: "BotterTests",
            dependencies: ["Botter"]),
    ]
)
