@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PledgeOverTimePaymentScheduleViewControllerTest: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_PaymentSchedule_Collapsed() {
    let increments = mockPaymentIncrements()
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeOverTimePaymentScheduleViewController.instantiate()

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 80

        controller.configure(with: increments)

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PaymentSchedule_Expanded() {
    let designSystemOn = MockRemoteConfigClient()
    designSystemOn.features = [
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    let increments = mockPaymentIncrements()
    orthogonalCombos(
      [Language.en],
      [Device.pad, Device.phone4_7inch],
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    ).forEach { language, device, style in
      withEnvironment(
        colorResolver: AppColorResolver(),
        language: language,
        remoteConfigClient: designSystemOn
      ) {
        let controller = PledgeOverTimePaymentScheduleViewController.instantiate()
        controller.overrideUserInterfaceStyle = style

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 520

        controller.configure(with: increments)
        controller.collapseToggle()

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "lang_\(language)_device_\(device)_style_\(style.description)"
        )
      }
    }
  }
}
