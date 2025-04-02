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
        let view = RewardTrackingDetailsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        let data = RewardTrackingDetailsViewData(
          trackingNumber: "1234567890",
          trackingURL: URL(string: "http://ksr.com")!,
          style: .backingDetails
        )

        view.configure(with: data)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 140

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ActivityStyle() {
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let view = RewardTrackingDetailsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        let data = RewardTrackingDetailsViewData(
          trackingNumber: "1234567890",
          trackingURL: URL(string: "http://ksr.com")!,
          style: .activity
        )

        view.configure(with: data)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: wrappedViewController(subview: view, device: device)
        )
        parent.view.frame.size.height = 140

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}

private func wrappedViewController(subview: UIView, device: Device) -> UIViewController {
  let controller = UIViewController(nibName: nil, bundle: nil)
  let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

  controller.view.addSubview(subview)

  NSLayoutConstraint.activate([
    subview.leadingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.leadingAnchor),
    subview.topAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.topAnchor),
    subview.trailingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.trailingAnchor),
    subview.bottomAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.bottomAnchor)
  ])

  return parent
}
