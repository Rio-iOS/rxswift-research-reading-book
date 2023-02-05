// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "chapter02",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "chapter02",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "chapter02Tests",
            dependencies: ["chapter02", .product(name: "RxTest", package: "RxSwift")]),
    ]
)
