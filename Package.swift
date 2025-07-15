// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "CompositionStringConvertible",
  products: [
    .library(
      name: "CompositionStringConvertible",
      targets: ["CompositionStringConvertible"]
    )
  ],
  targets: [
    .target(
      name: "CompositionStringConvertible"
    ),
    .testTarget(
      name: "CompositionStringConvertibleTests",
      dependencies: ["CompositionStringConvertible"]
    ),
  ]
)
