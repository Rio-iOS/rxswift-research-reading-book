// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "chapter03",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "chapter03",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "chapter03Tests",
            dependencies: ["chapter03", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
