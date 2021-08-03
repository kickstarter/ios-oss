@testable import KsApi
import XCTest

final class DeletePaymentSourceEnvelope_PaymentSourceDeleteMutationTests: XCTestCase {
  func testPaymentSource_WithValidData_Success() {
    // NOTE: Cannot convert directly from a String to the payment type, state or type. Apollo seems to return the Mutation.Data with these types created.
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
    XCTAssertEqual(env.storedCards.first!.id, "69021326")
    XCTAssertEqual(env.storedCards.first!.expirationDate, "2023-02-01")
    XCTAssertEqual(env.storedCards.first!.lastFour, "4242")
    XCTAssertEqual(env.storedCards.first!.type, .visa)
    XCTAssertEqual(env.storedCards.last!.id, "69021329")
    XCTAssertEqual(env.storedCards.last!.expirationDate, "2024-01-01")
    XCTAssertEqual(env.storedCards.last!.lastFour, "4243")
    XCTAssertEqual(env.storedCards.last!.type, .discover)
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

    let data = GraphAPI.CreatePaymentSourceMutation.Data(unsafeResultMap: resultMap)

    let env = CreatePaymentSourceEnvelope.from(data)

    XCTAssertNil(env)
  }
}
