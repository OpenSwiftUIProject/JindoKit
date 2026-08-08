import ActivityKit

public struct DemoActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var etaMinutes: Int
        public var progress: Double
        public var sequence: Int

        public init(
            etaMinutes: Int,
            progress: Double,
            sequence: Int = 1
        ) {
            self.etaMinutes = etaMinutes
            self.progress = progress
            self.sequence = sequence
        }

        public static let preview = ContentState(
            etaMinutes: 12,
            progress: 0.68
        )
    }

    public var title: String

    public init(title: String) {
        self.title = title
    }

    public static let preview = DemoActivityAttributes(
        title: "Golden Gate Run"
    )
}
