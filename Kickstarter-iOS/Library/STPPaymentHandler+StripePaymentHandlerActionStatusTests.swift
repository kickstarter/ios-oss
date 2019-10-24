import Library
import Stripe
import XCTest

final class STPPaymentHandler_StripePaymentHandlerActionStatusTests: TestCase {
  func testTypeMapping() {
    XCTAssertEqual(
      STPPaymentHandler.ActionStatus.succeeded.status,
      StripePaymentHandlerActionStatus.succeeded
    )

    XCTAssertEqual(
      STPPaymentHandler.ActionStatus.canceled.status,
      StripePaymentHandlerActionStatus.canceled
    )

    XCTAssertEqual(
      STPPaymentHandler.ActionStatus.failed.status,
      StripePaymentHandlerActionStatus.failed
    )
  }
}
