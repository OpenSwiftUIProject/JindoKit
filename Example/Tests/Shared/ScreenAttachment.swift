import UIKit
import XCTest

@MainActor
func addScreenAttachment(
    _ screenshot: XCUIScreenshot,
    to testCase: XCTestCase,
    named name: String,
    topHeight: CGFloat
) {
    let image = screenshot.image
    guard let source = image.cgImage else {
        XCTFail("Could not read screenshot pixels")
        return
    }

    let cropRect = CGRect(
        x: 0,
        y: 0,
        width: CGFloat(source.width),
        height: min(
            CGFloat(source.height),
            topHeight * image.scale
        )
    ).integral
    guard let cropped = source.cropping(to: cropRect) else {
        XCTFail("Could not crop screenshot")
        return
    }

    let croppedImage = UIImage(
        cgImage: cropped,
        scale: image.scale,
        orientation: image.imageOrientation
    )
    let attachment = XCTAttachment(image: croppedImage)
    attachment.name = name
    attachment.lifetime = .keepAlways
    testCase.add(attachment)
}
