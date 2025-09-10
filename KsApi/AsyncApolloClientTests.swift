@preconcurrency import Apollo
import GraphAPI
@testable import KsApi
import XCTest

final class AsyncApolloClientTests: XCTestCase {
  func testFetch_Errors_And_UpdatesCallbackQueue() async {
    let mock = MockApolloClient()
    mock.fetchShouldSucceed = false

    let queue = DispatchQueue(label: "fetchQueue")
    let asyncClient = AsyncApolloClient(client: mock, callbackQueue: queue)

    do {
      _ = try await asyncClient.fetch(StubQuery())

      XCTFail("Expected to throw an error but didn't")
    } catch {
      XCTAssertEqual(
        String(describing: error),
        String(describing: MockApolloClient.StubError.boom)
      )
    }

    XCTAssertIdentical(mock.lastFetchQueue, queue)
  }

  func testPerform_Errors_And_UpdatesCallbackQueue() async {
    let mock = MockApolloClient()
    mock.performShouldSucceed = false

    let queue = DispatchQueue(label: "performQueue")
    let asyncClient = AsyncApolloClient(client: mock, callbackQueue: queue)

    do {
      _ = try await asyncClient.perform(StubMutation())

      XCTFail("Expected to throw an error but didn't")
    } catch {
      XCTAssertEqual(
        String(describing: error),
        String(describing: MockApolloClient.StubError.boom)
      )
    }

    XCTAssertIdentical(mock.lastPerformQueue, queue)
  }

  func testFetch_Succeeds_And_UpdatesCallbackQueue() async throws {
    let mock = MockApolloClient()
    mock.fetchShouldSucceed = true

    let queue = DispatchQueue(label: "fetchQueue.success")
    let asyncClient = AsyncApolloClient(client: mock, callbackQueue: queue)

    let result: GraphQLResult<StubQuery.Data> = try await asyncClient.fetch(StubQuery())

    XCTAssertNotNil(result.data)
    XCTAssertIdentical(mock.lastFetchQueue, queue)
  }

  func testPerform_Succeeds_And_UpdatesCallbackQueue() async throws {
    let mock = MockApolloClient()
    mock.performShouldSucceed = true

    let queue = DispatchQueue(label: "performQueue.success")
    let asyncClient = AsyncApolloClient(client: mock, callbackQueue: queue)

    let result: GraphQLResult<StubMutation.Data> = try await asyncClient.perform(StubMutation())

    XCTAssertNotNil(result.data)
    XCTAssertIdentical(mock.lastPerformQueue, queue)
  }
}

// MARK: - Stub Query & Mutation

private final class StubQuery: GraphQLQuery {
  static var operationName: String { "StubQuery" }
  static var operationDocument: ApolloAPI.OperationDocument {
    .init(definition: .init("query StubQuery { __typename }"))
  }

  init() {}

  final class Data: GraphAPI.SelectionSet {
    static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    static var __selections: [GraphAPI.Selection] { [] }
    var __data: GraphAPI.DataDict
    required init(_dataDict: GraphAPI.DataDict) { self.__data = _dataDict }
  }
}

private final class StubMutation: GraphQLMutation {
  static var operationName: String { "StubMutation" }
  static var operationDocument: ApolloAPI.OperationDocument {
    .init(definition: .init("mutation StubMutation { __typename }"))
  }

  init() {}

  final class Data: GraphAPI.SelectionSet {
    static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    static var __selections: [GraphAPI.Selection] { [] }
    var __data: GraphAPI.DataDict
    required init(_dataDict: GraphAPI.DataDict) { self.__data = _dataDict }
  }
}
