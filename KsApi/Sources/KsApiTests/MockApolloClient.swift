import Apollo
import GraphAPI
import XCTest

/**
 A simple Apollo Mock used in our `AsyncApolloClientTests`.

 - Simulates Apollo for unit tests for `AsyncApolloClient`..
 - Ultimately calls `resultHandler` on the provided `DispatchQueue`.

 - Controlled by flags:
   - `fetchShouldSucceed` for `fetch(...)`
   - `performShouldSucceed` for `perform(...)`

 - On success: returns a minimal `GraphQLResult` with only `__typename`.
 - On failure: returns `StubError.boom`.

 - Records last queue/flags so tests can assert queue changes.
 */
public final class MockApolloClient: ApolloClientProtocol {
  enum StubError: Error, Equatable { case boom }

  /// `ApolloStore` requires a cache and `InMemoryNormalizedCache()` is the simplest, zero-IO choice for testing.
  public let store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache())

  /// Controls success/failure per call
  public var fetchShouldSucceed = false
  public var performShouldSucceed = false

  private(set) var lastFetchQueue: DispatchQueue?
  private(set) var lastPerformQueue: DispatchQueue?

  @discardableResult
  public func fetch<Query: GraphQLQuery>(
    query _: Query,
    cachePolicy _: Apollo.CachePolicy,
    contextIdentifier _: UUID?,
    context _: (any Apollo.RequestContext)?,
    queue: DispatchQueue,
    resultHandler: Apollo.GraphQLResultHandler<Query.Data>?
  ) -> Cancellable {
    self.lastFetchQueue = queue

    /// Mimic Apollo getting called on the provided queue
    queue.async {
      if self.fetchShouldSucceed {
        /// Build a minimal data payload for a Query
        let dataDict = GraphAPI.DataDict(data: ["__typename": "Query"], fulfilledFragments: [])
        let data = Query.Data(_dataDict: dataDict)

        let result = GraphQLResult<Query.Data>(
          data: data,
          extensions: nil,
          errors: nil,
          source: .server,
          dependentKeys: nil
        )

        resultHandler?(.success(result))
      } else {
        resultHandler?(.failure(StubError.boom))
      }
    }

    return EmptyCancellable() /// nothing to cancel in this mock.
  }

  @discardableResult
  public func perform<Mutation: GraphQLMutation>(
    mutation _: Mutation,
    publishResultToStore _: Bool,
    contextIdentifier _: UUID?,
    context _: (any Apollo.RequestContext)?,
    queue: DispatchQueue,
    resultHandler: Apollo.GraphQLResultHandler<Mutation.Data>?
  ) -> Cancellable {
    self.lastPerformQueue = queue

    /// Mimic Apollo getting called on the provided queue
    queue.async {
      if self.performShouldSucceed {
        /// Build a minimal data payload for a Mutation
        let dataDict = GraphAPI.DataDict(data: ["__typename": "Mutation"], fulfilledFragments: [])
        let data = Mutation.Data(_dataDict: dataDict)

        let result = GraphQLResult<Mutation.Data>(
          data: data,
          extensions: nil,
          errors: nil,
          source: .server,
          dependentKeys: nil
        )

        resultHandler?(.success(result))
      } else {
        resultHandler?(.failure(StubError.boom))
      }
    }
    return EmptyCancellable() /// nothing to cancel in this mock.
  }

  private class EmptyCancellable: Cancellable { func cancel() {} }

  // MARK: - Intentionally unimplemented methods to satisfy protocol conformance

  public func clearCache(callbackQueue _: DispatchQueue, completion _: ((Result<Void, Error>) -> Void)?) {}

  public func watch<Query>(
    query _: Query,
    cachePolicy _: Apollo.CachePolicy,
    context _: (any Apollo.RequestContext)?,
    callbackQueue _: DispatchQueue,
    resultHandler _: @escaping Apollo.GraphQLResultHandler<Query.Data>
  ) -> Apollo.GraphQLQueryWatcher<Query> where Query: ApolloAPI.GraphQLQuery {
    fatalError("watch(query): not implemented in MockApolloClient")
  }

  public func upload<Operation>(
    operation _: Operation,
    files _: [Apollo.GraphQLFile],
    context _: (any Apollo.RequestContext)?,
    queue _: DispatchQueue,
    resultHandler _: Apollo.GraphQLResultHandler<Operation.Data>?
  ) -> any Apollo.Cancellable
    where Operation: ApolloAPI
    .GraphQLOperation {
    fatalError("upload(operation): not implemented in MockApolloClient")
  }

  public func subscribe<Subscription>(
    subscription _: Subscription,
    context _: (any Apollo.RequestContext)?,
    queue _: DispatchQueue,
    resultHandler _: @escaping Apollo.GraphQLResultHandler<Subscription.Data>
  ) -> any Apollo.Cancellable
    where Subscription: ApolloAPI
    .GraphQLSubscription {
    fatalError("subscribe(subscription): not implemented in MockApolloClient")
  }
}
