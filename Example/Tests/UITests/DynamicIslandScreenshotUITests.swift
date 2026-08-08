import XCTest

@MainActor
final class DynamicIslandScreenshotUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCapturePresentations() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-reset-live-activities",
        ]
        app.launch()

        XCTAssertTrue(
            app.otherElements["jindokit-preview-screen"]
                .waitForExistence(timeout: 10)
        )
        XCTAssertTrue(
            app.staticTexts["live-activity-status"]
                .waitForExistence(timeout: 10)
        )

        let presentationIdentifiers = [
            "jindokit-expanded",
            "jindokit-compact",
            "jindokit-minimal",
        ]
        for identifier in presentationIdentifiers {
            XCTAssertTrue(
                app.descendants(matching: .any)[identifier].exists
            )
        }

        let clearedStatus = NSPredicate(
            format: "label CONTAINS[c] %@",
            "cleared"
        )
        expectation(
            for: clearedStatus,
            evaluatedWith: app.staticTexts["live-activity-status"]
        )
        waitForExpectations(timeout: 15)

        sleep(1)
        addScreenAttachment(
            app.screenshot(),
            to: self,
            named: "01-JindoKit-presentations",
            topHeight: 500
        )

        app.buttons["start-primary-activity"].tap()

        let activeStatus = NSPredicate(
            format: "label CONTAINS[c] %@",
            "active"
        )
        expectation(
            for: activeStatus,
            evaluatedWith: app.staticTexts["live-activity-status"]
        )
        waitForExpectations(timeout: 15)

        XCUIDevice.shared.press(.home)

        let springboard = XCUIApplication(
            bundleIdentifier: "com.apple.springboard"
        )
        XCTAssertTrue(
            springboard.wait(for: .runningForeground, timeout: 10)
        )

        sleep(2)
        addScreenAttachment(
            XCUIScreen.main.screenshot(),
            to: self,
            named: "02-WidgetKit-compact",
            topHeight: 180
        )

        let island = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.035)
        )
        island.press(forDuration: 1.2)

        sleep(1)
        addScreenAttachment(
            XCUIScreen.main.screenshot(),
            to: self,
            named: "03-WidgetKit-expanded",
            topHeight: 180
        )
    }
}
