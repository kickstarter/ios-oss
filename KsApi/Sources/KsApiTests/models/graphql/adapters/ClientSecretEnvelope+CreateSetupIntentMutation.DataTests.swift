@testable import KsApi
import XCTest

final class ClientSecretEnvelope_ClientSecretIntentMutationTests: XCTestCase {
  func testClientSecretEnvelopeCreation_Success() {
    guard let env = ClientSecretEnvelope
      .clientSecretEnvelope(from: CreateSetupIntentMutationTemplate.valid.data)
    else {
      XCTFail("ClientSecretEnvelope should exist.")

      return
    }

    XCTAssertEqual(env.clientSecret, "seti_1LO1Om4VvJ2PtfhKrNizQefl_secret_M6DqtRtur5tF3z0LRyh15x5VuHjFPQK")
    XCTAssertEqual(
      ClientSecretEnvelope.envelopeProducer(from: CreateSetupIntentMutationTemplate.valid.data).allValues()
        .count, 1
    )
  }

  func testClearUserUnseenActivity_Failure() {
    let env = ClientSecretEnvelope.clientSecretEnvelope(from: CreateSetupIntentMutationTemplate.errored.data)

    XCTAssertNil(env?.clientSecret)
  }
}
