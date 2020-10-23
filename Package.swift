// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "slox",
    products: [
        .executable(name: "slox", targets: ["slox"]),
        .library(name: "libslox", targets: ["libslox"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "slox", dependencies: ["libslox"]),
        .target(name: "libslox", dependencies: []),
        .testTarget(name: "sloxTests", dependencies: ["slox"]),
    ]
)
