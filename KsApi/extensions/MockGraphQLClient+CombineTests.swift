import Combine
@testable import KsApi
import XCTest

final class MockGraphQLClient_CombineTests: XCTestCase {
  func testSuccess() {
    let mockClient = MockGraphQLClient()
    let observer = CombineTestObserver<UserEnvelope<GraphUserEmail>, ErrorEnvelope>()

    let fetchGraphUserEmailQuery = GraphAPI.FetchUserEmailQuery()
    let fetchUserEmailQueryData = GraphAPI.FetchUserEmailQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<GraphUserEmail>.userEnvelope(from: fetchUserEmailQueryData) else {
      XCTFail()
      return
    }

    let publisher: AnyPublisher<UserEnvelope<GraphUserEmail>, ErrorEnvelope> =
      mockClient.fetchWithResult(query: fetchGraphUserEmailQuery, result: .success(envelope))

    observer.observe(publisher)

    XCTAssertEqual(observer.events.count, 1)

    if case let .value(observedEnvelope) = observer.events.last {
      XCTAssertEqual(observedEnvelope.me, envelope.me)
    } else {
      XCTFail()
    }
  }

  func testFailure() {
    let mockClient = MockGraphQLClient()
    let observer = CombineTestObserver<UserEnvelope<GraphUserEmail>, ErrorEnvelope>()

    let fetchGraphUserEmailQuery = GraphAPI.FetchUserEmailQuery()
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong"],
      ksrCode: .GraphQLError,
      httpCode: 503,
      exception: nil
    )

    let publisher: AnyPublisher<UserEnvelope<GraphUserEmail>, ErrorEnvelope> =
      mockClient.fetchWithResult(query: fetchGraphUserEmailQuery, result: .failure(error))

    observer.observe(publisher)

    XCTAssertEqual(observer.events.count, 1)

    if case let .error(observedError) = observer.events.last {
      XCTAssertEqual(observedError.ksrCode, error.ksrCode)
      XCTAssertEqual(observedError.errorMessages, error.errorMessages)
    } else {
      XCTFail()
    }
  }
}
