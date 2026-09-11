// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "chapter06",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.5.0"))
    ],
    targets: [
        .executableTarget(
            name: "chapter06",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "chapter06Tests",
            dependencies: ["chapter06", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
