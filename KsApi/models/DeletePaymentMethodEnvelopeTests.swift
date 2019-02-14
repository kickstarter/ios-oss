import XCTest
@testable import KsApi

class DeletePaymentMethodEnvelopeTests: XCTestCase {

  func testDeletePaymentMethodEnvelopeDecoding() {

    let jsonString = """
        {
          "paymentSourceDelete": {
              "user": {
                "storedCards": {
                  "totalCount": 0
                }
              }
          }
        }
        """
    let data = jsonString.data(using: .utf8)

    do {
      //swiftlint:disable force_unwrapping
      let envelope = try JSONDecoder().decode(DeletePaymentMethodEnvelope.self, from: data!)
        XCTAssertEqual(envelope.totalCount, 0)
    } catch {
      XCTFail("DeletePaymentMethodEnvelope should be decoded!")
    }
  }
}
