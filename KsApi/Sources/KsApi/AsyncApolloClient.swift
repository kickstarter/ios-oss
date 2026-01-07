@preconcurrency import Apollo
import Foundation
import GraphAPI

/**
 An async/await wrapper around `ApolloClientProtocol`.

 Purpose:
    - bridge Apollo’s callback APIs with Swift Concurrency.

 Callback queue:
    - all Apollo completions run on `callbackQueue`(defaults to `.global(qos: .userInitiated)`.

 Methods:
    - `fetch(_:)`: forwards `cachePolicy`/`contextIdentifier`
      - returns `GraphQLResult`or throws an Apollo error.
    - `perform(_:)`: forwards `publishResultToStore`
      - returns `GraphQLResult`or throws an Apollo error.

 Concurrency: marked `@unchecked Sendable`. queue hopping is controlled by `callbackQueue`.

 */
public final class AsyncApolloClient: @unchecked Sendable {
  private let client: ApolloClientProtocol
  private let callbackQueue: DispatchQueue

  /// `callbackQueue` defaults to a background queue..
  public init(
    client: ApolloClientProtocol,
    /// using `.userInitiated` for scheduling the work the user is waiting on  more efficiently.. `.background` can sometimes get deprioritized.
    callbackQueue: DispatchQueue = .global(qos: .userInitiated)
  ) {
    self.client = client
    self.callbackQueue = callbackQueue
  }

  // MARK: - Queries

  public func fetch<Query: GraphQLQuery>(
    _ query: Query,
    cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
    contextIdentifier: UUID? = nil
  ) async throws -> GraphQLResult<Query.Data> {
    try await withCheckedThrowingContinuation { cont in
      _ = self.client.fetch(
        query: query,
        cachePolicy: cachePolicy,
        contextIdentifier: contextIdentifier,
        context: nil,
        queue: self.callbackQueue
      ) { result in
        switch result {
        case let .success(value): cont.resume(returning: value)
        case let .failure(error): cont.resume(throwing: error)
        }
      }
    }
  }

  // MARK: - Mutations

  public func perform<Mutation: GraphQLMutation>(
    _ mutation: Mutation,
    publishResultToStore: Bool = true
  ) async throws -> GraphQLResult<Mutation.Data> {
    try await withCheckedThrowingContinuation { cont in
      _ = self.client.perform(
        mutation: mutation,
        publishResultToStore: publishResultToStore,
        context: nil,
        queue: self.callbackQueue
      ) { result in
        switch result {
        case let .success(value): cont.resume(returning: value)
        case let .failure(error): cont.resume(throwing: error)
        }
      }
    }
  }
}
