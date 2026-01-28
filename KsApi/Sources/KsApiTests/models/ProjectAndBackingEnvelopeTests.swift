import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
@testable import KsApiTestHelpers
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
    let producer = Backing.producer(from: data)

    guard let backing = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(backing.id, 1)
    XCTAssertEqual(backing.projectId, 987)
    XCTAssertEqual(backing.status, .pledged)
    XCTAssertEqual(backing.paymentIncrements.count, 0)
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
    let producer = Backing.producer(from: data)

    guard let backing = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(backing.id, 1)
    XCTAssertEqual(backing.projectId, 987)
    XCTAssertEqual(backing.status, .pledged)
    XCTAssertEqual(backing.paymentIncrements.count, 3)

    XCTAssertEqual(backing.paymentIncrements[0].state, .collected)
    XCTAssertEqual(backing.paymentIncrements[0].refundStatus, .notRefunded)

    XCTAssertEqual(backing.paymentIncrements[1].state, .collected)
    if case let .partialRefund(amount) = backing.paymentIncrements[1].refundStatus {
      XCTAssertEqual(amount.amountFormattedInProjectNativeCurrency, "$23.00")
    }

    XCTAssertEqual(backing.paymentIncrements[2].state, .refunded)
    XCTAssertEqual(backing.paymentIncrements[2].refundStatus, .fullRefund)
  }
}
