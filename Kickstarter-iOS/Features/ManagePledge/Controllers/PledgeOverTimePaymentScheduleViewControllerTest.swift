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
    let increments = incrementsWithRefundedItems()

    orthogonalCombos([Language.en], [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeOverTimePaymentScheduleViewController.instantiate()

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 580

        controller.configure(with: increments)
        controller.collapseToggle()

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}

private func incrementsWithRefundedItems() -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let scheduledCollection = TimeInterval(1_553_731_200)

  let adjustedRefundedAmount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$55.00"
  )

  let collectedAdjustedIncrement = PledgePaymentIncrement(
    amount: amount,
    scheduledCollection: scheduledCollection,
    state: .collected,
    stateReason: nil,
    refundedAmount: adjustedRefundedAmount
  )

  let refundedAmount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )

  let refundedIncrement = PledgePaymentIncrement(
    amount: amount,
    scheduledCollection: scheduledCollection,
    state: .refunded,
    stateReason: nil,
    refundedAmount: refundedAmount
  )

  return mockPaymentIncrements() + [collectedAdjustedIncrement, refundedIncrement]
}
