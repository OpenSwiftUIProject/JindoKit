# JindoKit

JindoKit brings WidgetKit-style Dynamic Island presentations to SwiftUI apps.

## Installation

Add JindoKit to your package dependencies:

```swift
.package(
    url: "https://github.com/OpenSwiftUIProject/JindoKit.git",
    from: "0.2.0"
)
```

Then add the `JindoKit` product to your target.

The default `SwiftUI_NO_SPI` backend uses SwiftUI and JindoKit's open source
implementation of the Dynamic Island layout. It doesn't link the system
`SwiftUI_SPI` module.

The four backend traits are mutually exclusive. Omit `traits` to use
`SwiftUI_NO_SPI`, or select exactly one of the other three.

### SwiftUI SPI

Enable the `SwiftUI_SPI` package trait to compare against the system Jindo
layout:

```swift
.package(
    url: "https://github.com/OpenSwiftUIProject/JindoKit.git",
    from: "0.2.0",
    traits: ["SwiftUI_SPI"]
)
```

This configuration links the private system SwiftUI SPI and is intended only
for local development and compatibility testing, not App Store distribution.

### OpenSwiftUI

Enable the `OpenSwiftUI_NO_SPI` package trait to use JindoKit's open source
layout with OpenSwiftUI:

```swift
.package(
    url: "https://github.com/OpenSwiftUIProject/JindoKit.git",
    from: "0.2.0",
    traits: ["OpenSwiftUI_NO_SPI"]
)
```

Import `OpenSwiftUI` instead of `SwiftUI` in an OpenSwiftUI app. The JindoKit
API is otherwise unchanged. To compare against OpenSwiftUI's Jindo layout SPI,
select the `OpenSwiftUI_SPI` trait instead. Both OpenSwiftUI backends require
Swift 6.3 and iOS 18 or later. They inherit OpenSwiftUI's runtime dependencies
and should not be treated as App Store-safe alternatives to the default
backend.

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

To generate the system SwiftUI SPI configuration:

```sh
Example/setup.sh --sui
```

To explicitly generate the SwiftUI open source configuration:

```sh
Example/setup.sh --sui-no-spi
```

To generate the OpenSwiftUI open source configuration:

```sh
Example/setup.sh --osui-no-spi
```

To generate the OpenSwiftUI SPI configuration instead:

```sh
Example/setup.sh --osui
```

Open `Example/JindoKitExample.xcworkspace` and run the `JindoKitExample`
scheme. The default configuration compares JindoKit with a pure WidgetKit
Extension. All configurations embed that Extension and can start a real Live
Activity from the App.
