// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-web",
  products: [
    .executable(name: "TypedAssetsCLI", targets: ["TypedAssetsCLI"]),
    .plugin(name: "TypedAssetsPlugin", targets: ["TypedAssetsPlugin"]),
    .library(name: "HummingbirdURLRouting", targets: ["HummingbirdURLRouting"]),
    .library(name: "MiddlewareUtils", targets: ["MiddlewareUtils"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", exact: "0.6.2"),
    .package(url: "https://github.com/pointfreeco/swift-clocks.git", exact: "1.0.6")
  ],
  targets: [
    .executableTarget(
      name: "TypedAssetsCLI",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .plugin(
      name: "TypedAssetsPlugin", 
      capability: .buildTool(),
      dependencies: [
        .target(name: "TypedAssetsCLI")
      ]
    ),
    .target(
      name: "HummingbirdURLRouting",
      dependencies: [
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
      ]
    ),
    .target(
      name: "MiddlewareUtils",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "Clocks", package: "swift-clocks")
      ],
      resources: [.embedInCode("Resources")]
    )
  ]
)
