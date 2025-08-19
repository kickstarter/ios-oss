@preconcurrency import Apollo
import Foundation
import GraphAPI

public extension ApolloClient {
  /// GraphQL query using async/await.
  /// Returns `GraphQLResult`
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
}
