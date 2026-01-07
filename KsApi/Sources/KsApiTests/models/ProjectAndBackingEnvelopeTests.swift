import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class ProjectAndBackingEnvelopeTests: XCTestCase {
  // MARK: - FetchBackingQuery

  func test_fromFetchBackingQuery_withoutPaymentIncrements() {
    let mock = Mock<GraphAPITestMocks.Query>()

    mock.backing = GraphAPITestMocks.Backing.mock

    let data = GraphAPI.FetchBackingQuery.Data.from(mock)
    let producer = ProjectAndBackingEnvelope.envelopeProducer(from: data)

    guard let envelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.backing.id, 1)
    XCTAssertEqual(envelope.backing.projectId, 987)
    XCTAssertEqual(envelope.backing.status, .pledged)
    XCTAssertEqual(envelope.backing.paymentIncrements.count, 0)
  }

  func test_envelopeObject_fromFetchBackingQuery_withPaymentIncrements() {
    let mock = Mock<GraphAPITestMocks.Query>()

    mock.backing = GraphAPITestMocks.Backing.mock
    mock.backing?.paymentIncrements = [GraphAPITestMocks.PaymentIncrement.collectedMock]

    let data = GraphAPI.FetchBackingQuery.Data.from(mock)
    let producer = ProjectAndBackingEnvelope.envelopeProducer(from: data)

    guard let envelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.backing.id, 1)
    XCTAssertEqual(envelope.backing.projectId, 987)
    XCTAssertEqual(envelope.backing.status, .pledged)
    XCTAssertEqual(envelope.backing.paymentIncrements.count, 1)
    XCTAssertEqual(envelope.backing.paymentIncrements[0].refundStatus, .unknown)
  }

  // MARK: - FetchBackingWithIncrementsRefundedQuery

  func test_envelopeObject_fromFetchBackingWithIncrementsRefundedQuery_withoutPaymentIncrements() {
    let mock = Mock<GraphAPITestMocks.Query>()

    mock.backing = GraphAPITestMocks.Backing.mock

    let data = GraphAPI.FetchBackingWithIncrementsRefundedQuery.Data.from(mock)
    let producer = ProjectAndBackingEnvelope.envelopeProducer(from: data)

    guard let envelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.backing.id, 1)
    XCTAssertEqual(envelope.backing.projectId, 987)
    XCTAssertEqual(envelope.backing.status, .pledged)
    XCTAssertEqual(envelope.backing.paymentIncrements.count, 0)
  }

  func test_envelopeObject_fromFetchBackingWithIncrementsRefundedQuery_withMixedIncrementStates() {
    let mock = Mock<GraphAPITestMocks.Query>()

    mock.backing = GraphAPITestMocks.Backing.mock
    mock.backing?.paymentIncrements = [
      GraphAPITestMocks.PaymentIncrement.collectedMock,
      GraphAPITestMocks.PaymentIncrement.collectedAdjustedMock,
      GraphAPITestMocks.PaymentIncrement.refundedMock
    ]

    let data = GraphAPI.FetchBackingWithIncrementsRefundedQuery.Data.from(mock)
    let producer = ProjectAndBackingEnvelope.envelopeProducer(from: data)

    guard let envelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.backing.id, 1)
    XCTAssertEqual(envelope.backing.projectId, 987)
    XCTAssertEqual(envelope.backing.status, .pledged)
    XCTAssertEqual(envelope.backing.paymentIncrements.count, 3)

    XCTAssertEqual(envelope.backing.paymentIncrements[0].state, .collected)
    XCTAssertEqual(envelope.backing.paymentIncrements[0].refundStatus, .notRefunded)

    XCTAssertEqual(envelope.backing.paymentIncrements[1].state, .collected)
    if case let .refunded(amount) = envelope.backing.paymentIncrements[1].refundStatus {
      XCTAssertEqual(amount.amountFormattedInProjectNativeCurrency, "$20.00")
    }

    XCTAssertEqual(envelope.backing.paymentIncrements[2].state, .refunded)
    if case let .refunded(amount) = envelope.backing.paymentIncrements[2].refundStatus {
      XCTAssertEqual(amount.amountFormattedInProjectNativeCurrency, "$43.00")
    }
  }
}
