@preconcurrency import Apollo
import Foundation
import GraphAPI

/*
 An async/await wrapper around Apollo 1.x.
 */

/// Using @unchecked because Apollo types aren’t fully Sendable-annotated.
public final class AsyncApolloClient: @unchecked Sendable {
  private let client: ApolloClientProtocol /// Existing Apollo protocol

  public init(client: ApolloClientProtocol) {
    self.client = client
  }

  // MARK: - Queries

  public func fetch<Query: GraphQLQuery>(
    _ query: Query,
    cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
    contextIdentifier: UUID? = nil,
    queue: DispatchQueue = .main
  ) async throws -> GraphQLResult<Query.Data> {
    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<
      GraphQLResult<Query.Data>,
      Error
    >) in
      /// Kick off Apollo's callback-style request
      _ = self.client.fetch(
        query: query,
        cachePolicy: cachePolicy,
        contextIdentifier: contextIdentifier,
        context: nil,
        queue: queue
      ) { result in
        /// resume via async/await
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
    publishResultToStore: Bool = true,
    queue: DispatchQueue = .main
  ) async throws -> GraphQLResult<Mutation.Data> {
    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<
      GraphQLResult<Mutation.Data>,
      Error
    >) in
      /// Kick off Apollo's callback-style request
      _ = self.client.perform(
        mutation: mutation,
        publishResultToStore: publishResultToStore,
        context: nil,
        queue: queue
      ) { result in
        /// resume via async/await
        switch result {
        case let .success(value): cont.resume(returning: value)
        case let .failure(error): cont.resume(throwing: error)
        }
      }
    }
  }
}
