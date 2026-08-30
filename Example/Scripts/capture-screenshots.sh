#!/bin/zsh

set -euo pipefail

example_directory=${0:A:h:h}
jindokit_directory=${example_directory:h}
derived_directory="$jindokit_directory/Derived"
destination=${DESTINATION:-"platform=iOS Simulator,name=iPhone 17 Pro,OS=latest"}
screenshot_directory="$example_directory/Screenshots"

mkdir -p "$derived_directory"
capture_directory=$(mktemp -d "$derived_directory/ScreenshotCapture.XXXXXX")
result_bundle="$capture_directory/JindoKitExample.xcresult"
attachment_directory="$capture_directory/Attachments"
staged_screenshot_directory="$capture_directory/Screenshots"

cleanup() {
    exit_status=$1
    if (( exit_status == 0 )); then
        rm -rf "$capture_directory"
    else
        print -u2 "Preserved failed capture at $capture_directory"
    fi
}
trap 'cleanup $?' EXIT

env \
    -u JINDOKIT_SWIFTUI_NO_SPI \
    -u JINDOKIT_SWIFTUI_SPI \
    -u JINDOKIT_OPENSWIFTUI_NO_SPI \
    -u JINDOKIT_OPENSWIFTUI_SPI \
    "$example_directory/setup.sh"

xcodebuild -quiet \
    -workspace "$example_directory/JindoKitExample.xcworkspace" \
    -scheme JindoKitScreenshotCapture \
    -destination "$destination" \
    -derivedDataPath "$capture_directory/DerivedData" \
    -resultBundlePath "$result_bundle" \
    test

xcrun xcresulttool export attachments \
    --path "$result_bundle" \
    --output-path "$attachment_directory"

typeset -A expected_screenshots=(
    01-JindoKit-presentations 1
    02-WidgetKit-compact 1
    03-WidgetKit-expanded 1
)
captured_count=0
mkdir -p "$staged_screenshot_directory"

while IFS=$'\t' read -r suggested_name exported_name; do
    stable_name=${suggested_name%%_0_*}
    if [[ -n ${expected_screenshots[$stable_name]-} ]]; then
        staged_path="$staged_screenshot_directory/$stable_name.png"
        if [[ -e "$staged_path" ]]; then
            print -u2 "Duplicate screenshot attachment: $stable_name"
            exit 1
        fi
        cp "$attachment_directory/$exported_name" "$staged_path"
        ((captured_count += 1))
    fi
done < <(
    /usr/bin/jq -r \
        '.[] | .attachments[] |
        [.suggestedHumanReadableName, .exportedFileName] | @tsv' \
        "$attachment_directory/manifest.json"
)

if (( captured_count != ${#expected_screenshots} )); then
    print -u2 \
        "Expected ${#expected_screenshots} screenshots, captured $captured_count"
    exit 1
fi

mkdir -p "$screenshot_directory"
/usr/bin/rsync -a --delete \
    "$staged_screenshot_directory/" \
    "$screenshot_directory/"

print "Saved screenshots to $screenshot_directory"
