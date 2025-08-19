import Apollo
import Foundation
import GraphAPI

public extension ApolloClient {
  /// GraphQL query using async/await.
  /// Returns `GraphQLResult` (may include data and/or errors).
  @preconcurrency
  func fetch<Query: GraphQLQuery>(query: Query) async throws -> GraphQLResult<Query.Data> {
    try await withCheckedThrowingContinuation { continuation in
      self.fetch(query: query) { result in
        switch result {
        case let .success(value): continuation.resume(returning: value)
        case let .failure(error): continuation.resume(throwing: error)
        }
      }
    }
  }

  /// GraphQL mutation using async/await.
  /// Returns `GraphQLResult` (may include data and/or errors).
  @preconcurrency
  func performAsync<Mutation: GraphQLMutation>(mutation: Mutation) async throws
    -> GraphQLResult<Mutation.Data> {
    try await withCheckedThrowingContinuation { continuation in
      self.perform(mutation: mutation) { result in
        switch result {
        case let .success(value): continuation.resume(returning: value)
        case let .failure(error): continuation.resume(throwing: error)
        }
      }
    }
  }
}
