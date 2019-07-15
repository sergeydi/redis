// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "Redbird",
	products: [
      .library(
            name: "Redbird",
            targets: ["Redbird"])
    ],
	dependencies: [
		.package(url: "https://github.com/vapor/socks.git", from: "1.2.7")
	],
	targets: [
		.target(name: "Redbird", dependencies: ["Socks"])
	]
)
