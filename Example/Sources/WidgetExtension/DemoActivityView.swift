import JindoKitExampleActivityShared
import JindoKitExamplePresentationShared
import SwiftUI

struct DemoActivityView: View {
    let attributes: DemoActivityAttributes
    let state: DemoActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.blue.gradient)

                    Image(systemName: "figure.run")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(attributes.title)
                        .font(.headline)

                    Label(
                        "\(state.etaMinutes) min remaining",
                        systemImage: "timer"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text("\(Int(state.progress * 100))%")
                    .font(.title3.bold())
                    .monospacedDigit()
            }

            ProgressView(value: state.progress)
                .tint(.mint)
        }
    }
}
