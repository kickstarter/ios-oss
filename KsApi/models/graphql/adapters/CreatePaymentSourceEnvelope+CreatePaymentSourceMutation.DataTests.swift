@testable import KsApi
import XCTest

final class CreatePaymentSourceEnvelope_CreatePaymentSourceMutationTests: XCTestCase {
  func testPaymentSource_WithValidData_Success() {
    // NOTE: Cannot convert directly from a String to the payment type, state or type. Apollo seems to return the Mutation.Data with these types created.
    let resultMap: [String: Any?] = [
      "createPaymentSource": [
        "__typename": "CreatePaymentSourcePayload",
        "clientMutationId": nil,
        "isSuccessful": true,
        "paymentSource": [
          "__typename": "CreditCard",
          "expirationDate": "2032-02-01",
          "id": "69021299",
          "lastFour": "4242",
          "paymentType": GraphAPI.PaymentTypes.creditCard,
          "state": GraphAPI.CreditCardState.active,
          "type": GraphAPI.CreditCardTypes.visa
        ]
      ]
    ]

    let data = GraphAPI.CreatePaymentSourceMutation.Data(unsafeResultMap: resultMap)

    guard let env = CreatePaymentSourceEnvelope.from(data) else {
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
    let dict: [String: Any] = [
      "createPaymentSource": [
        "clientMutationId": nil,
        "isSuccessful": false,
        "paymentSource": [
          "expirationDate": "2032-02-01",
          "id": "69021299",
          "lastFour": "4242",
          "type": "VISA"
        ]
      ]
    ]

    let data = GraphAPI.CreatePaymentSourceMutation.Data(unsafeResultMap: dict)

    let env = CreatePaymentSourceEnvelope.from(data)

    XCTAssertNil(env)
  }
}
