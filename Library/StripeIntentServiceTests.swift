@testable import KsApi
@testable import Library
import XCTest

final class StripeIntentServiceTests: XCTestCase {
  func testCreatePaymentIntent_IsRequestedWithExpectedData() {
    let mockStripeIntentService = MockStripeIntentService()
    let testPaymentIntentEnvelope = PaymentIntentEnvelope(clientSecret: "test")
    let expectedData = [StripeIntentRequestTestData(
      projectId: "test-project",
      pledgeTotal: 10,
      paymentIntentEnvelope: testPaymentIntentEnvelope,
      context: nil,
      clientSeretEnvelope: nil
    )]

    _ = mockStripeIntentService.createPaymentIntent(for: "test-project", pledgeTotal: 10)

    XCTAssertEqual([testPaymentIntentEnvelope], mockStripeIntentService.requestedPaymentIntentEnvelopes)
    XCTAssertEqual(expectedData, mockStripeIntentService.intentRequests)
  }

  func testCreateSetupIntent_IsRequestedWithExpectedData() {
    let mockStripeIntentService = MockStripeIntentService()
    let testSetupIntentEnvelope = ClientSecretEnvelope(clientSecret: "test")
    let expectedData = [StripeIntentRequestTestData(
      projectId: "test-project",
      pledgeTotal: nil,
      paymentIntentEnvelope: nil,
      context: GraphAPI.StripeIntentContextTypes.postCampaignCheckout,
      clientSeretEnvelope: testSetupIntentEnvelope
    )]

    _ = mockStripeIntentService.createSetupIntent(for: "test-project", context: .postCampaignCheckout)

    XCTAssertEqual([testSetupIntentEnvelope], mockStripeIntentService.requestedSetupIntentEnvelopes)
    XCTAssertEqual(expectedData, mockStripeIntentService.intentRequests)
  }
}
