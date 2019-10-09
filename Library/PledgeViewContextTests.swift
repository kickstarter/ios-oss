@testable import Library
import XCTest

final class PledgeViewContextTests: TestCase {
  func testPledge() {
    let context = PledgeViewContext.pledge

    XCTAssertTrue(context.confirmationLabelHidden)
    XCTAssertFalse(context.continueViewHidden)
    XCTAssertFalse(context.descriptionViewHidden)
    XCTAssertFalse(context.isUpdating)
    XCTAssertTrue(context.isCreating)
    XCTAssertFalse(context.paymentMethodsViewHidden)
    XCTAssertFalse(context.sectionSeparatorsHidden)
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
    XCTAssertTrue(context.sectionSeparatorsHidden)
    XCTAssertEqual(context.submitButtonTitle, "Confirm")
    XCTAssertEqual(context.title, "Change payment method")
  }
}
