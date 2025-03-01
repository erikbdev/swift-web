// swift-tools-version: 6.0.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-web",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "HTML", targets: ["HTML"]),
    .library(name: "Vue", targets: ["Vue"]),
    .executable(name: "TypedAssetsCLI", targets: ["TypedAssetsCLI"]),
    .plugin(name: "TypedAssetsPlugin", targets: ["TypedAssetsPlugin"]),
    .library(name: "HummingbirdURLRouting", targets: ["HummingbirdURLRouting"]),
    .library(name: "MiddlewareUtils", targets: ["MiddlewareUtils"])
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-clocks.git", from: "1.0.6"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.0"),
    .package(url: "https://github.com/sliemeobn/elementary.git", from: "0.4.0")
  ],
  targets: [
    /// Typed Assets
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

    /// Hummingbird URL Routing
    .target(
      name: "HummingbirdURLRouting",
      dependencies: [
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
      ]
    ),

    /// Middleware Utils
    .target(
      name: "MiddlewareUtils",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "Clocks", package: "swift-clocks")
      ],
      resources: [.embedInCode("Resources")]
    ),

    /// Vue
    .macro(
      name: "VueMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .target(
      name: "Vue",
      dependencies: [
        "VueMacros",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Elementary", package: "elementary")
      ]
    ),
    .testTarget(
      name: "VueTests", 
      dependencies: [
        "Vue",
        "VueMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing")
      ]
    ),

    /// HTML
    .target(
      name: "HTML",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ]
    ),
    .testTarget(
      name: "HTMLTests",
      dependencies: [
        "HTML"
      ]
    )
  ]
)
