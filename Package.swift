// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "slox",
    products: [
      .executable(name: "slox", targets: ["Slox"]),
      .executable(name: "genslox", targets: ["Gen"]),
      .executable(name: "past", targets: ["Past"]),
      .library(name: "Libslox", targets: ["Libslox"]),
    ],
    dependencies: [
      // Dependencies declare other packages that this package depends on.
      // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
      .target(name: "Slox", dependencies: ["Libslox"]),
      .target(name: "Past", dependencies: ["Libslox"]),
      .target(name: "Gen", dependencies: []),
      .target(name: "Libslox", dependencies: []),
      .testTarget(name: "LibsloxTests", dependencies: ["Libslox"]),
    ]
)
