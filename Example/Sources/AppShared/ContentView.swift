import Foundation
import JindoKit
import JindoKitExampleActivityShared

#if OpenSwiftUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ContentView: View {
    @State private var activityStatus = LiveActivityService.idleStatus

    private let attributes = DemoActivityAttributes.preview
    private let state = DemoActivityAttributes.ContentState.preview

    var body: some View {
        #if OpenSwiftUI
        content
            .task {
                await handleLaunchArguments()
            }
        #else
        ScrollView {
            content
                .exampleAccessibilityContainer(
                    identifier: "jindokit-preview-screen"
                )
        }
        .task {
            await handleLaunchArguments()
        }
        #endif
    }

    private var content: some View {
        VStack(spacing: 14) {
            VStack(spacing: 3) {
                Text("JindoKit API")
                    .font(.title2.bold())

                Text("Same content and parameters as WidgetKitExtension")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            jindoIsland(mode: .expanded)
                .exampleAccessibilityContainer(
                    identifier: "jindokit-expanded"
                )

            HStack(spacing: 24) {
                previewColumn(title: "Compact") {
                    jindoIsland(mode: .compact)
                        .exampleAccessibilityContainer(
                            identifier: "jindokit-compact"
                        )
                }

                previewColumn(title: "Minimal") {
                    jindoIsland(mode: .minimal)
                        .exampleAccessibilityContainer(
                            identifier: "jindokit-minimal"
                        )
                }
            }

            Divider()

            activityControl

            Text(activityStatus)
                .font(.caption)
                .foregroundStyle(Color.secondary)
                .exampleAccessibilityIdentifier(
                    "live-activity-status"
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }

    private var activityControl: some View {
        #if OpenSwiftUI
        Text("Start WidgetKit Activity")
            .font(.headline)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(Color.blue)
            }
            .onTapGesture {
                startActivity()
            }
        #else
        Button("Start WidgetKit Activity") {
            startActivity()
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("start-primary-activity")
        #endif
    }

    private func previewColumn<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Color.secondary)
            content()
        }
    }

    private func jindoIsland(
        mode: DynamicIslandPreviewMode
    ) -> some View {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                DemoExpandedLeadingView(state: state)
            }

            DynamicIslandExpandedRegion(
                .trailing,
                priority: DemoIslandLayout.trailingPriority
            ) {
                DemoExpandedTrailingView()
            }

            DynamicIslandExpandedRegion(.bottom) {
                DemoExpandedBottomView(
                    attributes: attributes,
                    state: state
                )
                .dynamicIsland(verticalPlacement: .belowIfTooWide)
            }
            .contentMargins(
                .horizontal,
                DemoIslandLayout.regionHorizontalMargin
            )
        } compactLeading: {
            DemoCompactLeadingView(state: state)
        } compactTrailing: {
            DemoCompactTrailingView()
        } minimal: {
            DemoMinimalView()
        }
        .contentMargins(
            .all,
            DemoIslandLayout.expandedAllMargin,
            for: .expanded
        )
        .previewMode(mode)
    }

    private func startActivity() {
        Task { @MainActor in
            activityStatus = await LiveActivityService.resetAndStart()
        }
    }

    @MainActor
    private func handleLaunchArguments() async {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-reset-live-activities") {
            activityStatus = await LiveActivityService.reset()
            return
        }

        guard arguments.contains(
            "-auto-start-live-activity"
        ) else {
            return
        }
        activityStatus = await LiveActivityService.resetAndStart()
    }
}

private extension View {
    func exampleAccessibilityContainer(
        identifier: String
    ) -> some View {
        #if OpenSwiftUI
        self
        #else
        accessibilityElement(children: .contain)
            .accessibilityIdentifier(identifier)
        #endif
    }

    func exampleAccessibilityIdentifier(
        _ identifier: String
    ) -> some View {
        #if OpenSwiftUI
        self
        #else
        accessibilityIdentifier(identifier)
        #endif
    }
}
