@preconcurrency import Apollo
import Foundation
import GraphAPI

/// Minimal async/await wrapper for Apollo
public final class AsyncApolloClient: @unchecked Sendable {
  private let client: ApolloClientProtocol
  // One place to decide where Apollo invokes its completion.
  private let callbackQueue: DispatchQueue

  /// `callbackQueue` defaults to a background queue; pass `.main` if you truly want main.
  public init(
    client: ApolloClientProtocol,
    /// using `.userInitiated` for lower latency/scheduling the work the user is waiting on  promptly. `.background` can sometimes get deprioritized.
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
