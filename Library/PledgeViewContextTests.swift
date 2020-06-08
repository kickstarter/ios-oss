@testable import Library
import XCTest

final class PledgeViewContextTests: TestCase {
  func testFixPaymentMethod() {
    let context = PledgeViewContext.fixPaymentMethod

    XCTAssertTrue(context.confirmationLabelHidden)
    XCTAssertTrue(context.continueViewHidden)
    XCTAssertTrue(context.descriptionViewHidden)
    XCTAssertTrue(context.isUpdating)
    XCTAssertFalse(context.isCreating)
    XCTAssertFalse(context.paymentMethodsViewHidden)
    XCTAssertTrue(context.pledgeAmountViewHidden)
    XCTAssertFalse(context.pledgeAmountSummaryViewHidden)
    XCTAssertTrue(context.sectionSeparatorsHidden)
    XCTAssertEqual(context.submitButtonTitle, "Confirm")
    XCTAssertEqual(context.title, "Fix payment method")
  }

  func testPledge() {
    let context = PledgeViewContext.pledge

    XCTAssertFalse(context.confirmationLabelHidden)
    XCTAssertFalse(context.continueViewHidden)
    XCTAssertFalse(context.descriptionViewHidden)
    XCTAssertFalse(context.isUpdating)
    XCTAssertTrue(context.isCreating)
    XCTAssertFalse(context.paymentMethodsViewHidden)
    XCTAssertFalse(context.pledgeAmountViewHidden)
    XCTAssertTrue(context.pledgeAmountSummaryViewHidden)
    XCTAssertFalse(context.sectionSeparatorsHidden)
    XCTAssertFalse(context.shippingLocationViewHidden)
    XCTAssertEqual(context.submitButtonTitle, "Pledge")
    XCTAssertEqual(context.title, "Back this project")
  }

  func testUpdate() {
    let context = PledgeViewContext.update

    XCTAssertFalse(context.confirmationLabelHidden)
    XCTAssertTrue(context.continueViewHidden)
    XCTAssertTrue(context.descriptionViewHidden)
    XCTAssertTrue(context.isUpdating)
    XCTAssertFalse(context.isCreating)
    XCTAssertTrue(context.paymentMethodsViewHidden)
    XCTAssertFalse(context.pledgeAmountViewHidden)
    XCTAssertTrue(context.pledgeAmountSummaryViewHidden)
    XCTAssertTrue(context.sectionSeparatorsHidden)
    XCTAssertEqual(context.submitButtonTitle, "Confirm")
    XCTAssertEqual(context.title, "Update pledge")
  }

  func testChangePaymentMethod() {
    let context = PledgeViewContext.changePaymentMethod

    XCTAssertTrue(context.confirmationLabelHidden)
    XCTAssertTrue(context.continueViewHidden)
    XCTAssertTrue(context.descriptionViewHidden)
    XCTAssertTrue(context.isUpdating)
    XCTAssertFalse(context.isCreating)
    XCTAssertFalse(context.paymentMethodsViewHidden)
    XCTAssertTrue(context.pledgeAmountViewHidden)
    XCTAssertFalse(context.pledgeAmountSummaryViewHidden)
    XCTAssertTrue(context.sectionSeparatorsHidden)
    XCTAssertEqual(context.submitButtonTitle, "Confirm")
    XCTAssertEqual(context.title, "Change payment method")
  }

  func testUpdateReward() {
    let context = PledgeViewContext.updateReward

    XCTAssertTrue(context.confirmationLabelHidden)
    XCTAssertTrue(context.continueViewHidden)
    XCTAssertFalse(context.descriptionViewHidden)
    XCTAssertTrue(context.isUpdating)
    XCTAssertFalse(context.isCreating)
    XCTAssertTrue(context.paymentMethodsViewHidden)
    XCTAssertFalse(context.pledgeAmountViewHidden)
    XCTAssertTrue(context.pledgeAmountSummaryViewHidden)
    XCTAssertFalse(context.sectionSeparatorsHidden)
    XCTAssertEqual(context.submitButtonTitle, "Confirm")
    XCTAssertEqual(context.title, "Update pledge")
  }
}
