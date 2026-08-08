#if OpenSwiftUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Testing
@testable import JindoKit

@Suite
struct DynamicIslandAPITests {
    @MainActor
    @Test
    func widgetKitShapedAPICompiles() {
        let island = makeIsland()
            .contentMargins(.trailing, 8, for: .expanded)
            .contentMargins(.all, 20, for: .expanded)
            .previewMode(.compact)

        #expect(type(of: island) == DynamicIsland.self)
    }

    #if !OpenSwiftUI
    @MainActor
    @Test
    func everyPresentationRenders() {
        for mode in [
            DynamicIslandPreviewMode.expanded,
            .compact,
            .minimal,
        ] {
            let renderer = ImageRenderer(
                content: makeIsland().previewMode(mode)
            )
            renderer.scale = 1

            #expect(renderer.uiImage != nil)
        }
    }
    #endif

    @Test
    func defaultPreviewConfiguration() {
        let configuration = DynamicIslandPreviewConfiguration.default

        #expect(configuration.notchSize == CGSize(width: 126, height: 37))
        #expect(
            configuration.compactObstructionSize == CGSize(width: 119.33, height: 37)
        )
        #expect(configuration.expandedSize == CGSize(width: 371, height: 160))
        #expect(configuration.compactSize == CGSize(width: 230, height: 37))
        #expect(configuration.minimalSize == CGSize(width: 45, height: 37))
    }

    @Test
    func firstContentMarginModifierWinsPerEdge() {
        var margins = DynamicIslandContentMargins(12)
        margins.set(.trailing, to: 8)
        margins.set(.all, to: 20)

        #expect(margins.edgeInsets.top == 20)
        #expect(margins.edgeInsets.leading == 20)
        #expect(margins.edgeInsets.bottom == 20)
        #expect(margins.edgeInsets.trailing == 8)
    }

    @MainActor
    private func makeIsland() -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                Text("Leading")
            }
            DynamicIslandExpandedRegion(.trailing, priority: 1) {
                Text("Trailing")
            }
            DynamicIslandExpandedRegion(.bottom) {
                Text("Bottom")
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
            }
            .contentMargins(.horizontal, 8)
        } compactLeading: {
            Text("L")
        } compactTrailing: {
            Text("T")
        } minimal: {
            Text("M")
        }
    }
}
