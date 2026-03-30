@testable import Kickstarter_Framework
@testable import Library
@testable import LibraryTestHelpers
import SnapshotTesting
import UIKit

final class VideoFeedViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_VideoFeedCell() {
    // TODO: Update to all languages once translations are in [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    orthogonalCombos(
      [Language.en],
      Device.allCases
    ).forEach {
      language, device in

      withEnvironment(language: language) {
        let cell = VideoFeedCell(frame: CGRect(
          x: 0,
          y: 0,
          width: device.deviceSize.width,
          height: device.deviceSize.height
        ))
        
        cell.configureWith(value: .init(
          id: "0",
          title: "Ringo Move - The Ultimate Workout Bottle",
          creator: "Creator Name",
          statsText: "$50,134 pledged · Join 431 backers",
          categoryPillText: "Project We Love",
          secondaryPillText: "3 days left",
          ctaTitle: "Back this project"
        ))

        assertSnapshot(
          matching: cell,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
