@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class RewardTrackingDetailsViewTest: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_BackingDetailsStyle() {
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = RewardTrackingDetailsView(style: .backingDetails)
        view.translatesAutoresizingMaskIntoConstraints = false

        let data = RewardTrackingDetailsViewData(
          trackingNumber: "1234567890",
          trackingURL: URL(string: "http://ksr.com")!
        )

        view.configure(with: data)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: traitWrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 140

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ActivityStyle() {
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = RewardTrackingDetailsView(style: .activity)
        view.translatesAutoresizingMaskIntoConstraints = false

        let data = RewardTrackingDetailsViewData(
          trackingNumber: "1234567890",
          trackingURL: URL(string: "http://ksr.com")!
        )

        view.configure(with: data)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: traitWrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 140

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
