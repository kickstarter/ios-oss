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

    let requestedEnvelopes = mockStripeIntentService.intentRequests.map { $0.paymentIntentEnvelope }

    XCTAssertEqual([testPaymentIntentEnvelope], requestedEnvelopes)
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

    let requestedEnvelopes = mockStripeIntentService.intentRequests.map { $0.clientSeretEnvelope }

    XCTAssertEqual([testSetupIntentEnvelope], requestedEnvelopes)
    XCTAssertEqual(expectedData, mockStripeIntentService.intentRequests)
  }
}
