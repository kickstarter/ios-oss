import Foundation
@testable import KsApi
import Prelude
import XCTest

final class BackingPaymentSourceTests: XCTestCase {
  func testJSONDecoding_CompleteData() {
    let jsonDictionary: [String: Any] = [
      "expiration_date": "2020-02-21",
      "id": "2",
      "last_four": "4111",
      "payment_type": "CREDIT_CARD",
      "state": "ACTIVE",
      "type": "VISA"
    ]

    let paymentSource: Backing.PaymentSource? = Backing.PaymentSource
      .decodeJSONDictionary(jsonDictionary).value ?? nil

    XCTAssertEqual(paymentSource?.expirationDate, "2020-02-21")
    XCTAssertEqual(paymentSource?.id, "2")
    XCTAssertEqual(paymentSource?.lastFour, "4111")
    XCTAssertEqual(paymentSource?.paymentType, PaymentType.creditCard)
    XCTAssertEqual(paymentSource?.state, "ACTIVE")
    XCTAssertEqual(paymentSource?.type, CreditCardType.visa)
  }

  func testJSONDecoding_IncompleteData() {
    let jsonDictionary: [String: Any?] = [
      "expiration_date": nil,
      "id": nil,
      "last_four": nil,
      "payment_type": "CREDIT_CARD",
      "state": "ACTIVE",
      "type": nil
    ]

    let paymentSource: Backing.PaymentSource? = Backing.PaymentSource
      .decodeJSONDictionary(jsonDictionary as [String: Any]).value ?? nil

    XCTAssertNil(paymentSource?.expirationDate)
    XCTAssertNil(paymentSource?.id)
    XCTAssertNil(paymentSource?.lastFour)
    XCTAssertNil(paymentSource?.type)
    XCTAssertEqual(paymentSource?.paymentType, PaymentType.creditCard)
    XCTAssertEqual(paymentSource?.state, "ACTIVE")
  }

  func testJSONDecoding_ApplePay() {
    let jsonDictionary: [String: Any] = [
      "expiration_date": "2020-02-21",
      "id": "2",
      "last_four": "4111",
      "payment_type": "APPLE_PAY",
      "state": "ACTIVE",
      "type": "VISA"
    ]

    let paymentSource: Backing.PaymentSource? = Backing.PaymentSource
      .decodeJSONDictionary(jsonDictionary).value ?? nil

    XCTAssertEqual(paymentSource?.expirationDate, "2020-02-21")
    XCTAssertEqual(paymentSource?.id, "2")
    XCTAssertEqual(paymentSource?.lastFour, "4111")
    XCTAssertEqual(paymentSource?.paymentType, PaymentType.applePay)
    XCTAssertEqual(paymentSource?.state, "ACTIVE")
    XCTAssertEqual(paymentSource?.type, CreditCardType.visa)
  }

  func testJSONDecoding_GooglePay() {
    let jsonDictionary: [String: Any] = [
      "expiration_date": "2020-02-21",
      "id": "2",
      "last_four": "4111",
      "payment_type": "ANDROID_PAY",
      "state": "ACTIVE",
      "type": "VISA"
    ]

    let paymentSource: Backing.PaymentSource? = Backing.PaymentSource
      .decodeJSONDictionary(jsonDictionary).value ?? nil

    XCTAssertEqual(paymentSource?.expirationDate, "2020-02-21")
    XCTAssertEqual(paymentSource?.id, "2")
    XCTAssertEqual(paymentSource?.lastFour, "4111")
    XCTAssertEqual(paymentSource?.paymentType, PaymentType.googlePay)
    XCTAssertEqual(paymentSource?.state, "ACTIVE")
    XCTAssertEqual(paymentSource?.type, CreditCardType.visa)
  }

  func testDecodingFailure() {
    let jsonDictionary: [String: Any?] = [
      "expiration_date": "2020-02-21",
      "id": "2",
      "last_four": "4111",
      "payment_type": nil,
      "state": nil,
      "type": "VISA"
    ]

    let paymentSource: Backing.PaymentSource? = Backing.PaymentSource
      .decodeJSONDictionary(jsonDictionary as [String: Any]).value ?? nil

    XCTAssertNil(paymentSource)
  }
}
