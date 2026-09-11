// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "chapter01",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.5.0"))
    ],
    targets: [
        .executableTarget(
            name: "chapter01",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "chapter01Tests",
            dependencies: ["chapter01", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
