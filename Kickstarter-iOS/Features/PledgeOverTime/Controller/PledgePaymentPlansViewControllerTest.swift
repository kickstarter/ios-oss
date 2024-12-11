@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class PledgePaymentPlansViewControllerTest: TestCase {
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

  func testView_PledgeInFullSelected() {
    let project = Project.template
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgePaymentPlansViewController.instantiate()

        let data = PledgePaymentPlansAndSelectionData(selectedPlan: .pledgeInFull, project: project)
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 400

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeOverTimeSelected() {
    let project = Project.template
    let testIncrements = testPledgePaymentIncrement()
    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgePaymentPlansViewController.instantiate()

        let data = PledgePaymentPlansAndSelectionData(
          selectedPlan: .pledgeOverTime,
          increments: testIncrements,
          project: project
        )
        controller.configure(with: data)

        controller.pledgePaymentPlanOptionView(
          PledgePaymentPlanOptionView(),
          didSelectPlanType: .pledgeOverTime
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 400

        self.scheduler.advance(by: .seconds(3))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}

private func testPledgePaymentIncrement() -> [PledgePaymentIncrement] {
  var increments: [PledgePaymentIncrement] = []
  var timeStamp = Date().timeIntervalSince1970
  for _ in 1...4 {
    timeStamp += 30 * 24 * 60 * 60
    increments.append(PledgePaymentIncrement(
      amount: PledgePaymentIncrementAmount(amount: 250.0, currency: "USD"),
      scheduledCollection: timeStamp
    ))
  }

  return increments
}
