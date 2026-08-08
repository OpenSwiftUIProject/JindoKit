import JindoKitExampleActivityShared

#if OpenSwiftUI
import OpenSwiftUI
#else
import SwiftUI
#endif

public enum DemoIslandLayout {
    public static let trailingPriority = 1.0
    public static let regionHorizontalMargin = 8.0
    public static let expandedAllMargin = 20.0
}

public struct DemoExpandedLeadingView: View {
    private let state: DemoActivityAttributes.ContentState

    public init(state: DemoActivityAttributes.ContentState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: "timer")
                .font(.caption)
                .foregroundStyle(Color.mint)

            Text("\(state.etaMinutes) MIN")
                .font(.caption2.bold())
                .monospacedDigit()
        }
    }
}

public struct DemoExpandedTrailingView: View {
    public init() {}

    public var body: some View {
        ZStack {
            #if OpenSwiftUI
            Circle()
                .fill(Color.blue)
            #else
            Circle()
                .fill(Color.blue.gradient)
            #endif

            Image(systemName: "figure.run")
                .font(.caption.bold())
                .foregroundStyle(Color.white)
        }
        .frame(width: 32, height: 32)
    }
}

public struct DemoExpandedBottomView: View {
    private let attributes: DemoActivityAttributes
    private let state: DemoActivityAttributes.ContentState

    public init(
        attributes: DemoActivityAttributes,
        state: DemoActivityAttributes.ContentState
    ) {
        self.attributes = attributes
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(attributes.title)
                    .font(.caption.bold())

                Spacer()

                Text("\(Int(state.progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.secondary)
            }

            ProgressView(value: state.progress)
                .tint(Color.mint)
        }
    }
}

public struct DemoCompactLeadingView: View {
    private let state: DemoActivityAttributes.ContentState

    public init(state: DemoActivityAttributes.ContentState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "timer")
                .foregroundStyle(Color.mint)

            Text("\(state.etaMinutes)")
                .font(.caption.bold())
                .monospacedDigit()
        }
    }
}

public struct DemoCompactTrailingView: View {
    public init() {}

    public var body: some View {
        Image(systemName: "figure.run")
            .font(.caption.bold())
            .foregroundStyle(Color.blue)
    }
}

public struct DemoMinimalView: View {
    public init() {}

    public var body: some View {
        Image(systemName: "figure.run")
            .font(.caption.bold())
            .foregroundStyle(Color.mint)
    }
}
