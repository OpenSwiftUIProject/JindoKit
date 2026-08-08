# JindoKit

JindoKit brings WidgetKit-style Dynamic Island presentations to SwiftUI apps.

## Installation

Add JindoKit to your package dependencies:

```swift
.package(
    url: "https://github.com/OpenSwiftUIProject/JindoKit.git",
    from: "0.1.0"
)
```

Then add the `JindoKit` product to your target.

### OpenSwiftUI

Enable the `OpenSwiftUI` package trait to use JindoKit with OpenSwiftUI:

```swift
.package(
    url: "https://github.com/OpenSwiftUIProject/JindoKit.git",
    from: "0.1.0",
    traits: ["OpenSwiftUI"]
)
```

Import `OpenSwiftUI` instead of `SwiftUI` in an OpenSwiftUI app. The JindoKit
API is otherwise unchanged. The OpenSwiftUI backend requires Swift 6.3 and
iOS 18 or later.

## Usage

```swift
import JindoKit
import SwiftUI

struct LiveActivityPreview: View {
    var body: some View {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                Text("12 min")
            }
            DynamicIslandExpandedRegion(.trailing) {
                Image(systemName: "figure.run")
            }
            DynamicIslandExpandedRegion(.bottom) {
                Text("Running to the finish")
            }
        } compactLeading: {
            Text("12")
        } compactTrailing: {
            Image(systemName: "figure.run")
        } minimal: {
            Image(systemName: "figure.run")
        }
        .contentMargins(.all, 20, for: .expanded)
    }
}
```

`DynamicIsland` is a `View` and displays the expanded presentation by default.
Use `.previewMode(.compact)` or `.previewMode(.minimal)` to render another
presentation.

## Example

[`Example/`](Example/) contains a Tuist-managed App that references the local
JindoKit Swift package. Generate its default SwiftUI configuration with:

```sh
Example/setup.sh
```

To generate the OpenSwiftUI-backed configuration instead:

```sh
Example/setup.sh --osui
```

Open `Example/JindoKitExample.xcworkspace` and run the `JindoKitExample`
scheme. The default configuration compares JindoKit with a pure WidgetKit
Extension. Both configurations embed that Extension and can start a real Live
Activity from the App.
