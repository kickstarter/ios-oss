@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import UIKit

final class PledgeRewardsSummaryTotalViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testViewWithReward() {
    let project = Project.template

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeRewardsSummaryTotalViewController.instantiate()

          let data = PledgeSummaryViewData(
            project: project,
            total: 10.0,
            confirmationLabelHidden: false,
            pledgeHasNoReward: false
          )

          controller.configure(with: data)
          controller.configureWith(pledgeOverTimeData: nil)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 200

          self.scheduler.advance(by: .seconds(1))

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testViewWithoutReward() {
    let project = Project.template

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeRewardsSummaryTotalViewController.instantiate()

          let data = PledgeSummaryViewData(
            project: project,
            total: 10.0,
            confirmationLabelHidden: false,
            pledgeHasNoReward: true
          )

          controller.configure(with: data)
          controller.configureWith(pledgeOverTimeData: nil)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 180

          self.scheduler.advance(by: .seconds(1))

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testViewWithPledgeInFull() {
    let project = Project.template

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeRewardsSummaryTotalViewController.instantiate()

          let data = PledgeSummaryViewData(
            project: project,
            total: 10.0,
            confirmationLabelHidden: false,
            pledgeHasNoReward: false
          )

          controller.configure(with: data)

          let paymentIncrements = mockPaymentIncrements()
          let plotData = PledgePaymentPlansAndSelectionData(
            selectedPlan: .pledgeInFull,
            increments: paymentIncrements,
            ineligible: false,
            project: project
          )

          controller.configureWith(pledgeOverTimeData: plotData)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 180

          self.scheduler.advance(by: .seconds(1))

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testViewWithPledgeOverTime() {
    let project = Project.template

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeRewardsSummaryTotalViewController.instantiate()

          let data = PledgeSummaryViewData(
            project: project,
            total: 10.0,
            confirmationLabelHidden: false,
            pledgeHasNoReward: false
          )

          controller.configure(with: data)

          let paymentIncrements = mockPaymentIncrements()
          let plotData = PledgePaymentPlansAndSelectionData(
            selectedPlan: .pledgeOverTime,
            increments: paymentIncrements,
            ineligible: false,
            project: project
          )

          controller.configureWith(pledgeOverTimeData: plotData)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 180

          self.scheduler.advance(by: .seconds(1))

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }
}
