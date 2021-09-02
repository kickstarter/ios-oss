@testable import KsApi
import XCTest

final class CreatePaymentSourceEnvelope_CreatePaymentSourceMutationTests: XCTestCase {
  func testPaymentSource_WithValidData_Success() {
    guard let env = CreatePaymentSourceEnvelope.from(CreatePaymentSourceMutationTemplate.valid.data)
    else {
      XCTFail("Payment source envelope should exist.")

      return
    }

    XCTAssertTrue(env.createPaymentSource.isSuccessful)
    XCTAssertEqual(env.createPaymentSource.paymentSource.id, "69021299")
    XCTAssertEqual(env.createPaymentSource.paymentSource.lastFour, "4242")
    XCTAssertEqual(env.createPaymentSource.paymentSource.type, .visa)
    XCTAssertEqual(env.createPaymentSource.paymentSource.expirationDate, "2032-02-01")
  }

  func testPaymentSource_WithInvalidData_Error() {
    let env = CreatePaymentSourceEnvelope.from(CreatePaymentSourceMutationTemplate.errored.data)

    XCTAssertNil(env)
  }
}
