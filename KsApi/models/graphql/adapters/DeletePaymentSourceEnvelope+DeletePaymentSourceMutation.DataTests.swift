@testable import KsApi
import XCTest

final class DeletePaymentSourceEnvelope_PaymentSourceDeleteMutationTests: XCTestCase {
  func testPaymentSource_WithValidData_Success() {
    let resultMap: [String: Any?] = [
      "paymentSourceDelete": [
        "user": [
          "storedCards": [
            "nodes": [
              [
                "expirationDate": "2023-02-01",
                "id": "69021326",
                "lastFour": "4242",
                "type": GraphAPI.CreditCardTypes.visa
              ],
              [
                "expirationDate": "2024-01-01",
                "id": "69021329",
                "lastFour": "4243",
                "type": GraphAPI.CreditCardTypes.discover
              ]
            ]
          ],
          "totalCount": 2
        ]
      ]
    ]

    let data = GraphAPI.DeletePaymentSourceMutation.Data(unsafeResultMap: resultMap)

    guard let env = DeletePaymentMethodEnvelope.from(data) else {
      XCTFail("Delete payment source envelope should exist.")

      return
    }

    XCTAssertEqual(env.storedCards.count, 2)

    guard let firstCard = env.storedCards.first,
      let secondCard = env.storedCards.last else {
      XCTFail()

      return
    }

    XCTAssertEqual(firstCard.id, "69021326")
    XCTAssertEqual(firstCard.expirationDate, "2023-02-01")
    XCTAssertEqual(firstCard.lastFour, "4242")
    XCTAssertEqual(firstCard.type, .visa)
    XCTAssertEqual(secondCard.id, "69021329")
    XCTAssertEqual(secondCard.expirationDate, "2024-01-01")
    XCTAssertEqual(secondCard.lastFour, "4243")
    XCTAssertEqual(secondCard.type, .discover)
  }

  func testPaymentSource_WithInvalidData_Error() {
    let resultMap: [String: Any?] = [
      "deletePaymentSource": [
        "user": [
          "storedCards": [
            "nodes": [
              [
                "expirationDate": "2023-02-01",
                "id": "69021326",
                "lastFour": "4242",
                "type": "VISA"
              ],
              [
                "expirationDate": "2024-01-01",
                "id": "69021329",
                "lastFour": "4243",
                "type": "DISCOVER"
              ]
            ]
          ],
          "totalCount": 2
        ]
      ]
    ]

    let data = GraphAPI.DeletePaymentSourceMutation.Data(unsafeResultMap: resultMap)

    let env = DeletePaymentMethodEnvelope.from(data)

    XCTAssertNil(env)
  }
}
