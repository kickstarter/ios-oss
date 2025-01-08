@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PledgeOverTimePaymentScheduleViewControllerTest: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_PaymentSchedule_Collapsed() {
    let project = Project.template
    let increments = mockPaymentIncrements()
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeOverTimePaymentScheduleViewController.instantiate()

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 80

        controller.configure(with: increments, project: project, collapsed: true)

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PaymentSchedule_Expanded() {
    let project = Project.template
    let increments = mockPaymentIncrements()
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeOverTimePaymentScheduleViewController.instantiate()

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 200

        controller.configure(with: increments, project: project, collapsed: false)

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
