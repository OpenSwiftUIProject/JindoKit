# JindoKit integration example

This Tuist project renders the same Dynamic Island content with JindoKit in
the App and WidgetKit in a Live Activity Extension. Both App backends embed the
same WidgetKit Extension and can start a real Live Activity.

## Generate

Generate the default SwiftUI configuration:

```sh
./setup.sh
```

Generate the OpenSwiftUI configuration instead:

```sh
./setup.sh --osui
```

Open `JindoKitExample.xcworkspace`, then run the `JindoKitExample` scheme on an
iPhone simulator.

## Capture screenshots

Run:

```sh
./Scripts/capture-screenshots.sh
```

The script generates the default SwiftUI configuration, runs the local
`JindoKitScreenshotUITests` target, and writes three PNGs to `Screenshots/`:

- JindoKit expanded, compact, and minimal previews in the App.
- The compact WidgetKit Live Activity in Dynamic Island.
- The expanded WidgetKit Live Activity after a long press.

`Screenshots/` is ignored by Git and is replaced on every run. Override the
simulator destination when needed:

```sh
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  ./Scripts/capture-screenshots.sh
```

The screenshot target is available only in the default SwiftUI configuration.
The capture script switches to that configuration automatically.
