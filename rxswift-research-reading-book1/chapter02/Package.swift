// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "chapter02",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        .executableTarget(
            name: "chapter02",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "chapter02Tests",
            dependencies: ["chapter02", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
