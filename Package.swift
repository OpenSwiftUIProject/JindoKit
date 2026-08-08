// swift-tools-version: 6.3

import PackageDescription

// MARK: - OpenSwiftUI integration

let useOpenSwiftUI =
    Context.environment["JINDOKIT_OPENSWIFTUI"] == "1"

let openSwiftUIDependency: Package.Dependency = .package(
    url: "https://github.com/OpenSwiftUIProject/OpenSwiftUI-spm.git",
    from: "0.21.0"
)

// MARK: - SPI interface integration

let swiftUISPIIncludePath =
    "\(Context.packageDirectory)/Artifacts/SwiftUI"
let openSwiftUISPIIncludePath =
    "\(Context.packageDirectory)/Artifacts/OpenSwiftUI"

let spiSwiftSettings: [SwiftSetting] = [
    .unsafeFlags(
        ["-I", swiftUISPIIncludePath],
        .when(traits: ["SwiftUI"])
    ),
    .unsafeFlags(
        ["-I", openSwiftUISPIIncludePath],
        .when(traits: ["OpenSwiftUI"])
    ),
]

let jindoKitSwiftSettings = spiSwiftSettings + [
    // Resilience keeps the internal SPI import out of normal clients while
    // allowing JindoKit to consume the selected raw SPI module.
    .unsafeFlags(["-enable-library-evolution"]),
]

var packageTraits: Set<Trait> = [
    .trait(name: "SwiftUI", description: "Use SwiftUI JindoKit"),
    .trait(name: "OpenSwiftUI", description: "Use OpenSwiftUI JindoKit"),
]
if useOpenSwiftUI {
    packageTraits.insert(.default(enabledTraits: ["OpenSwiftUI"]))
} else {
    packageTraits.insert(.default(enabledTraits: ["SwiftUI"]))
}

let package = Package(
    name: "JindoKit",
    platforms: [
        .iOS("16.1"),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "JindoKit",
            targets: ["JindoKit"]
        ),
    ],
    traits: packageTraits,
    dependencies: [
        openSwiftUIDependency,
    ],
    targets: [
        .target(
            name: "JindoKit",
            dependencies: [
                .product(
                    name: "OpenSwiftUI",
                    package: "OpenSwiftUI-spm",
                    condition: .when(traits: ["OpenSwiftUI"])
                ),
            ],
            swiftSettings: jindoKitSwiftSettings,
            linkerSettings: [
                .linkedFramework("SwiftUI", .when(traits: ["SwiftUI"]))
            ]
        ),
        .testTarget(
            name: "JindoKitTests",
            dependencies: [
                "JindoKit",
                .product(
                    name: "OpenSwiftUI",
                    package: "OpenSwiftUI-spm",
                    condition: .when(traits: ["OpenSwiftUI"])
                ),
            ],
            // @testable import exposes JindoKit's internal dependencies.
            swiftSettings: spiSwiftSettings
        ),
    ]
)
