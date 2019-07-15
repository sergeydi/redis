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
		.package(url: "https://github.com/sergeydi/sockets.git", .branch("1.2.8"))
	],
	targets: [
		.target(name: "Redbird", dependencies: ["Socks"])
	]
)
