// swift-tools-version: 6.3

import PackageDescription

// MARK: - Backend selection

enum JindoKitBackend: String, CaseIterable {
    case swiftUINoSPI = "SwiftUI_NO_SPI"
    case swiftUISPI = "SwiftUI_SPI"
    case openSwiftUINoSPI = "OpenSwiftUI_NO_SPI"
    case openSwiftUISPI = "OpenSwiftUI_SPI"

    var environmentKey: String {
        "JINDOKIT_\(rawValue.uppercased())"
    }

    var description: String {
        switch self {
        case .swiftUINoSPI:
            "SwiftUI JindoKit with OpenSwiftUI open source JindoTripleVStack implementation"
        case .swiftUISPI:
            "SwiftUI JindoKit with SwiftUI_SPI JindoTripleVStack implementation"
        case .openSwiftUINoSPI:
            "OpenSwiftUI JindoKit with OpenSwiftUI open source JindoTripleVStack implementation"
        case .openSwiftUISPI:
            "OpenSwiftUI JindoKit with OpenSwiftUI_SPI JindoTripleVStack implementation"
        }
    }

    var trait: Trait {
        .trait(name: rawValue, description: description)
    }

    var usesOpenSwiftUI: Bool {
        switch self {
        case .openSwiftUINoSPI, .openSwiftUISPI:
            true
        case .swiftUINoSPI, .swiftUISPI:
            false
        }
    }

    var usesSPI: Bool {
        switch self {
        case .swiftUISPI, .openSwiftUISPI:
            true
        case .swiftUINoSPI, .openSwiftUINoSPI:
            false
        }
    }

    static func selected(in environment: [String: String]) -> Self {
        let selected = allCases.filter {
            environment[$0.environmentKey] == "1"
        }
        guard selected.count <= 1 else {
            let keys = selected.map(\.environmentKey).joined(separator: ", ")
            fatalError("Set at most one JindoKit backend environment key: \(keys)")
        }
        return selected.first ?? .swiftUINoSPI
    }

    static let openSwiftUITraits = Set(
        allCases.filter(\.usesOpenSwiftUI).map(\.rawValue)
    )

    static let swiftUITraits = Set(
        allCases.filter { !$0.usesOpenSwiftUI }.map(\.rawValue)
    )

    static let spiTraits = Set(
        allCases.filter(\.usesSPI).map(\.rawValue)
    )
}

let selectedBackend = JindoKitBackend.selected(in: Context.environment)

// MARK: - OpenSwiftUI integration

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
        .when(traits: [JindoKitBackend.swiftUISPI.rawValue])
    ),
    .unsafeFlags(
        ["-I", openSwiftUISPIIncludePath],
        .when(traits: [JindoKitBackend.openSwiftUISPI.rawValue])
    ),
]

let jindoKitSwiftSettings = spiSwiftSettings + [
    // Resilience keeps the internal SPI import out of normal clients while
    // allowing JindoKit to consume the selected raw SPI module.
    .unsafeFlags(
        ["-enable-library-evolution"],
        .when(traits: JindoKitBackend.spiTraits)
    ),
]

var packageTraits = Set(JindoKitBackend.allCases.map(\.trait))
packageTraits.insert(.default(enabledTraits: [selectedBackend.rawValue]))

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
                    condition: .when(
                        traits: JindoKitBackend.openSwiftUITraits
                    )
                ),
            ],
            swiftSettings: jindoKitSwiftSettings,
            linkerSettings: [
                .linkedFramework(
                    "SwiftUI",
                    .when(traits: JindoKitBackend.swiftUITraits)
                )
            ]
        ),
        .testTarget(
            name: "JindoKitTests",
            dependencies: [
                "JindoKit",
                .product(
                    name: "OpenSwiftUI",
                    package: "OpenSwiftUI-spm",
                    condition: .when(
                        traits: JindoKitBackend.openSwiftUITraits
                    )
                ),
            ],
            // @testable import exposes JindoKit's internal dependencies.
            swiftSettings: spiSwiftSettings
        ),
    ]
)
