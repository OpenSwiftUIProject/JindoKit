import JindoKitExampleActivityShared
import JindoKitExamplePresentationShared
import SwiftUI
import WidgetKit

struct DemoLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DemoActivityAttributes.self) { context in
            DemoActivityView(
                attributes: context.attributes,
                state: context.state
            )
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DemoExpandedLeadingView(state: context.state)
                }

                DynamicIslandExpandedRegion(
                    .trailing,
                    priority: DemoIslandLayout.trailingPriority
                ) {
                    DemoExpandedTrailingView()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    DemoExpandedBottomView(
                        attributes: context.attributes,
                        state: context.state
                    )
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                .contentMargins(
                    .horizontal,
                    DemoIslandLayout.regionHorizontalMargin
                )
            } compactLeading: {
                DemoCompactLeadingView(state: context.state)
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
        }
    }
}

#Preview(
    "WidgetKit Activity",
    as: .content,
    using: DemoActivityAttributes.preview
) {
    DemoLiveActivityWidget()
} contentStates: {
    DemoActivityAttributes.ContentState.preview
}

#Preview(
    "WidgetKit Expanded",
    as: .dynamicIsland(.expanded),
    using: DemoActivityAttributes.preview
) {
    DemoLiveActivityWidget()
} contentStates: {
    DemoActivityAttributes.ContentState.preview
}

#Preview(
    "WidgetKit Compact",
    as: .dynamicIsland(.compact),
    using: DemoActivityAttributes.preview
) {
    DemoLiveActivityWidget()
} contentStates: {
    DemoActivityAttributes.ContentState.preview
}

#Preview(
    "WidgetKit Minimal",
    as: .dynamicIsland(.minimal),
    using: DemoActivityAttributes.preview
) {
    DemoLiveActivityWidget()
} contentStates: {
    DemoActivityAttributes.ContentState.preview
}
