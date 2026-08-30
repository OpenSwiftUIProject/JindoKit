import Foundation
import ProjectDescription

enum JindoKitBackend: String, CaseIterable {
    case swiftUINoSPI = "SwiftUI_NO_SPI"
    case swiftUISPI = "SwiftUI_SPI"
    case openSwiftUINoSPI = "OpenSwiftUI_NO_SPI"
    case openSwiftUISPI = "OpenSwiftUI_SPI"

    var environmentKey: String {
        "JINDOKIT_\(rawValue.uppercased())"
    }

    var packageTrait: Package.Dependency.Trait {
        .init(name: rawValue)
    }

    var usesOpenSwiftUI: Bool {
        switch self {
        case .openSwiftUINoSPI, .openSwiftUISPI:
            true
        case .swiftUINoSPI, .swiftUISPI:
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
}

let selectedBackend = JindoKitBackend.selected(
    in: ProcessInfo.processInfo.environment
)
let usesOpenSwiftUI = selectedBackend.usesOpenSwiftUI
let jindoKitTraits: Set<Package.Dependency.Trait> = [
    selectedBackend.packageTrait,
]

let packages: [Package.Dependency] = [
    .package(path: "..", traits: jindoKitTraits),
]

let deploymentTargets = DeploymentTargets.iOS("18.0")
let destinations: Destinations = [.iPhone]

let commonSettings: SettingsDictionary = [
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "",
    "SWIFT_VERSION": "6.0",
    "TARGETED_DEVICE_FAMILY": "1",
]

let appExtensionSettings: SettingsDictionary = [
    "APPLICATION_EXTENSION_API_ONLY": "YES",
    "SKIP_INSTALL": "YES",
]

let activitySharedTarget = Target.target(
    name: "JindoKitExampleActivityShared",
    destinations: destinations,
    product: .staticFramework,
    bundleId:
        "org.openswiftuiproject.openswiftui.jindokit.example.activityshared",
    deploymentTargets: deploymentTargets,
    infoPlist: .default,
    buildableFolders: ["Sources/ActivityShared"]
)

let presentationSharedTarget = Target.target(
    name: "JindoKitExamplePresentationShared",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.openswiftuiproject.openswiftui.jindokit.example.shared",
    deploymentTargets: deploymentTargets,
    infoPlist: .default,
    buildableFolders: ["Sources/PresentationShared"],
    dependencies: [
        .target(name: "JindoKitExampleActivityShared"),
    ]
)

let widgetExtensionTarget = Target.target(
    name: "JindoKitExampleWidgetExtension",
    destinations: destinations,
    product: .appExtension,
    bundleId: "org.openswiftuiproject.openswiftui.jindokit.example.widget",
    deploymentTargets: deploymentTargets,
    infoPlist: .extendingDefault(
        with: [
            "CFBundleDisplayName": "JindoKit Widget Reference",
            "NSExtension": [
                "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
            ],
        ]
    ),
    buildableFolders: ["Sources/WidgetExtension"],
    dependencies: [
        .target(name: "JindoKitExampleActivityShared"),
        .target(name: "JindoKitExamplePresentationShared"),
    ],
    settings: .settings(
        base: appExtensionSettings,
        defaultSettings: .essential
    )
)

let appDependencies: [TargetDependency] = [
    .package(product: "JindoKit"),
    .target(name: "JindoKitExampleActivityShared"),
    .target(name: "JindoKitExampleWidgetExtension"),
]

let appBuildableFolders: [BuildableFolder] = [
    "Sources/AppShared",
    "Sources/PresentationShared",
]

let appSettings = Settings.settings(
    base: usesOpenSwiftUI
        ? [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS":
                "$(inherited) OpenSwiftUI",
        ]
        : [:],
    defaultSettings: .essential
)

let appTarget = Target.target(
    name: "JindoKitExample",
    destinations: destinations,
    product: .app,
    bundleId: "org.openswiftuiproject.openswiftui.jindokit.example",
    deploymentTargets: deploymentTargets,
    infoPlist: .extendingDefault(
        with: [
            "CFBundleDisplayName": usesOpenSwiftUI
                ? "JindoKit OpenSwiftUI Example"
                : "JindoKit Example",
            "NSSupportsLiveActivities": .boolean(true),
            "UILaunchScreen": [:],
        ]
    ),
    buildableFolders: appBuildableFolders,
    dependencies: appDependencies,
    settings: appSettings
)

let screenshotTestsTarget = Target.target(
    name: "JindoKitScreenshotUITests",
    destinations: destinations,
    product: .uiTests,
    bundleId:
        "org.openswiftuiproject.openswiftui.jindokit.example.screenshottests",
    deploymentTargets: deploymentTargets,
    infoPlist: .default,
    buildableFolders: [
        "Tests/Shared",
        "Tests/UITests",
    ],
    dependencies: [
        .target(name: "JindoKitExample"),
    ]
)

var targets = [
    activitySharedTarget,
    presentationSharedTarget,
    widgetExtensionTarget,
    appTarget,
]
if !usesOpenSwiftUI {
    targets.append(screenshotTestsTarget)
}

var schemes: [Scheme] = [
    .scheme(
        name: "JindoKitExample",
        shared: true,
        buildAction: .buildAction(
            targets: [
                "JindoKitExample",
            ]
        ),
        runAction: .runAction(
            executable: "JindoKitExample"
        )
    ),
]
if !usesOpenSwiftUI {
    schemes.append(
        .scheme(
            name: "JindoKitScreenshotCapture",
            shared: true,
            buildAction: .buildAction(
                targets: [
                    "JindoKitExample",
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(
                        target: "JindoKitScreenshotUITests",
                        parallelization: .disabled
                    ),
                ]
            )
        )
    )
}

let project = Project(
    name: "JindoKitExample",
    options: .options(
        automaticSchemesOptions: .disabled,
        developmentRegion: "en"
    ),
    packages: packages,
    settings: .settings(
        base: commonSettings,
        defaultSettings: .essential
    ),
    targets: targets,
    schemes: schemes,
    additionalFiles: [
        "README.md",
        "Scripts/**",
        "mise.toml",
        "mise.sui-no-spi.toml",
        "mise.sui.toml",
        "mise.osui-no-spi.toml",
        "mise.osui.toml",
        "setup.sh",
    ]
)
