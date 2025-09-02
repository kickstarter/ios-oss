@preconcurrency import Apollo
import ApolloAPI
@testable import NextGenFeature
import XCTest

// Keep Data as a struct (SelectionSets are normally structs)
private struct DummyQueryData: GraphQLSelectionSet, Decodable {
  static var selections: [GraphQLSelection] { [] }
  var resultMap: ResultMap
  init(unsafeResultMap: ResultMap) { self.resultMap = unsafeResultMap }
  init(from _: Decoder) throws { self.resultMap = [:] }
}

private final class DummyQuery: GraphQLQuery {
  typealias Data = DummyQueryData
  let operationDefinition = "query Dummy { __typename }"
  let operationName = "Dummy"
  var variables: GraphQLMap? { nil }
}

// --- Mutation twin ---

private struct DummyMutationData: GraphQLSelectionSet, Decodable {
  static var selections: [GraphQLSelection] { [] }
  var resultMap: ResultMap
  init(unsafeResultMap: ResultMap) { self.resultMap = unsafeResultMap }
  init(from _: Decoder) throws { self.resultMap = [:] }
}

private final class DummyMutation: GraphQLMutation {
  typealias Data = DummyMutationData
  let operationDefinition = "mutation Dummy { __typename }"
  let operationName = "Dummy"
  var variables: GraphQLMap? { nil }
}

// A lightweight Apollo mock that just hands back whatever we told it to.
private final class MockApollo: ApolloClientProtocol {
  var fetchResult: Result<GraphQLResult<DummyQuery.Data>, Error>?
  var performResult: Result<GraphQLResult<DummyMutation.Data>, Error>?

  var didFetch = false
  var didPerform = false

  @discardableResult
  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy _: CachePolicy,
    contextIdentifier _: UUID?,
    context _: Any?,
    queue: DispatchQueue,
    resultHandler: @escaping GraphQLResultHandler<Query.Data>
  ) -> Cancellable {
    self.didFetch = true

    if query is DummyQuery, let fetchResult {
      // send it back on the requested queue like Apollo does
      queue.async {
        // swiftlint:disable:next force_cast
        resultHandler(fetchResult as! Result<GraphQLResult<Query.Data>, Error>)
      }
    } else {
      queue.async { resultHandler(.failure(NSError(domain: "FakeApollo", code: -1))) }
    }

    return Nop()
  }

  @discardableResult
  func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore _: Bool,
    context _: Any?,
    queue: DispatchQueue,
    resultHandler: @escaping GraphQLResultHandler<Mutation.Data>
  ) -> Cancellable {
    self.didPerform = true

    if mutation is DummyMutation, let performResult {
      queue.async {
        // swiftlint:disable:next force_cast
        resultHandler(performResult as! Result<GraphQLResult<Mutation.Data>, Error>)
      }
    } else {
      queue.async { resultHandler(.failure(NSError(domain: "FakeApollo", code: -2))) }
    }

    return Nop()
  }

  private struct Nop: Cancellable { func cancel() {} }
}

final class AsyncApolloClientTests: XCTestCase {
  func testFetch_success_roundTripsData() async throws {
    // set the table
    let fakeApollo = MockApollo()
    let client = AsyncApolloClient(client: fakeApollo)

    fakeApollo.fetchResult = .success(
      GraphQLResult(
        data: .init(unsafeResultMap: [:]),
        errors: nil,
        source: .server,
        dependentKeys: nil
      )
    )

    // act
    let result = try await client.fetch(DummyQuery())

    // assert
    XCTAssertNotNil(result.data, "bridge should deliver data back")
    XCTAssertTrue(fakeApollo.didFetch, "fake should have been called")
  }

  func testFetch_error_bubblesThroughContinuation() async {
    let fakeApollo = MockApollo()
    let client = AsyncApolloClient(client: fakeApollo)
    fakeApollo.fetchResult = .failure(NSError(domain: "X", code: 1))

    do {
      _ = try await client.fetch(DummyQuery())
      XCTFail("Expected an error, got success instead 😅")
    } catch {
      XCTAssertTrue(fakeApollo.didFetch)
    }
  }

  func testPerform_success_roundTripsData() async throws {
    let fakeApollo = MockApollo()
    let client = AsyncApolloClient(client: fakeApollo)

    fakeApollo.performResult = .success(
      GraphQLResult(
        data: .init(unsafeResultMap: [:]),
        errors: nil,
        source: .server,
        dependentKeys: nil
      )
    )

    let result = try await client.perform(DummyMutation())
    XCTAssertNotNil(result.data)
    XCTAssertTrue(fakeApollo.didPerform)
  }

  func testPerform_error_bubblesThroughContinuation() async {
    let fakeApollo = MockApollo()
    let client = AsyncApolloClient(client: fakeApollo)
    fakeApollo.performResult = .failure(NSError(domain: "Y", code: 2))

    do {
      _ = try await client.perform(DummyMutation())
      XCTFail("Expected an error here too")
    } catch {
      XCTAssertTrue(fakeApollo.didPerform)
    }
  }
}
