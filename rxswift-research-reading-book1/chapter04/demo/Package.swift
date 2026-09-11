// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "demo",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        .executableTarget(
            name: "demo",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "demoTests",
            dependencies: ["demo", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
