@testable import KsApi
import XCTest

class ClearUserUnseenActivityEnvelopeTests: XCTestCase {
  func testDecoding() {
    let jsonString = """
    {
      "clearUserUnseenActivity": {
        "clientMutationId": null,
        "activityIndicatorCount": 0
      }
    }
    """
    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(ClearUserUnseenActivityEnvelope.self, from: data)
      XCTAssertEqual(envelope.activityIndicatorCount, 0)
    } catch {
      XCTFail("Decode failed.")
    }
  }
}
