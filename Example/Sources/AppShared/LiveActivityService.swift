import ActivityKit
import Foundation
import JindoKitExampleActivityShared

@MainActor
enum LiveActivityService {
    static let idleStatus = "Live Activity is idle"

    static func resetAndStart() async -> String {
        _ = await reset()
        try? await Task.sleep(for: .milliseconds(500))
        return start()
    }

    static func reset() async -> String {
        for activity in Activity<DemoActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return "Live Activities cleared"
    }

    private static func start() -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return "Live Activities are disabled"
        }

        let content = ActivityContent(
            state: DemoActivityAttributes.ContentState.preview,
            staleDate: nil,
            relevanceScore: 1
        )

        do {
            _ = try Activity<DemoActivityAttributes>.request(
                attributes: .preview,
                content: content
            )
            return "Live Activity active"
        } catch {
            return "Live Activity failed: \(error.localizedDescription)"
        }
    }
}
