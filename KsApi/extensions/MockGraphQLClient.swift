import Apollo
import Foundation
import ReactiveSwift

class MockGraphQLClient: ApolloClientType {
  // MARK: - Base Properties

  var client: ApolloClient {
    let url = URL(string: "https://kickstarter.com")!

    return ApolloClient(url: url)
  }

  static let shared = MockGraphQLClient()

  // MARK: Public functions

  /// Placeholder implementation because protocol definition used in `Service`
  public func fetch<Query: GraphQLQuery>(query _: Query) -> SignalProducer<Query.Data, ErrorEnvelope> {
    .init(value: Query.Data(unsafeResultMap: [:]))
  }

  /// Placeholder implementation because protocol definition used in `Service`
  public func perform<Mutation: GraphQLMutation>(
    mutation _: Mutation
  ) -> SignalProducer<Mutation.Data, ErrorEnvelope> {
    .init(value: Mutation.Data(unsafeResultMap: [:]))
  }
}

/** Implementation of optional `fetch` and `perform` with `result` useful for mocking data.
 */
extension ApolloClientType {
  public func fetchWithResult<Query: GraphQLQuery, Data: Decodable>(
    query _: Query,
    result: Result<Data, ErrorEnvelope>?
  ) -> SignalProducer<Data, ErrorEnvelope> {
    producer(for: result)
  }

  public func performWithResult<Mutation: GraphQLMutation, Data: Decodable>(
    mutation _: Mutation,
    result: Result<Data, ErrorEnvelope>?
  ) -> SignalProducer<Data, ErrorEnvelope> {
    producer(for: result)
  }

  public func data<Data: Decodable>(from producer: SignalProducer<Data, ErrorEnvelope>) -> Data? {
    switch producer.first() {
    case let .success(data):
      return data
    default:
      return nil
    }
  }

  public func error<Data: Decodable>(from producer: SignalProducer<Data, ErrorEnvelope>)
    -> ErrorEnvelope? {
    switch producer.first() {
    case let .failure(errorEnvelope):
      return errorEnvelope
    default:
      return nil
    }
  }
}

private func producer<T, E>(for property: Result<T, E>?) -> SignalProducer<T, E> {
  guard let result = property else { return .empty }
  switch result {
  case let .success(value): return .init(value: value)
  case let .failure(error): return .init(error: error)
  }
}

private extension Result {
  var value: Success? {
    switch self {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  var error: Failure? {
    switch self {
    case .success: return nil
    case let .failure(error): return error
    }
  }
}

public final class MockApolloQuery: GraphQLQuery {
  public let operationDefinition: String = ""
  public let operationName: String = "OperationName"
  public let operationIdentifier: String? = "operation-identifier"

  public init() {}

  public var variables: GraphQLMap? {
    return [:]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]
    public static var selections: [GraphQLSelection] {
      return []
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }
  }
}
