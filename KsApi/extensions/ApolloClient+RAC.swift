import Apollo
import Foundation
import ReactiveSwift

class GraphQL {
  static let shared = GraphQL()

  func configure(
    with url: URL,
    headers: [String: String],
    additionalHeaders: @escaping () -> [String: String]
  ) {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = NetworkInterceptorProvider(store: store, additionalHeaders: additionalHeaders)
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url,
      additionalHeaders: headers
    )

    self.apollo = ApolloClient(networkTransport: transport, store: store)
  }

  private var apollo: ApolloClient?
  private(set) lazy var client: ApolloClient = {
    guard let client = self.apollo else {
      fatalError("Apollo Client accessed before calling configure(with:headers:additionalHeaders:)")
    }

    return client
  }()
}

extension ApolloClient {
  /**
   Creates an Apollo Client instance with the specified URL and headers.

   Note: this configuration matches the `ApolloClient`s own `init(url:)` initializer but
   allows us to pass in additional headers.

   - parameter url: The URL for the GraphQL endpoint.
   - parameter headers: Additional headers to configure each GraphQL request with.

   - returns: An `ApolloClient` instance.
   */
  static func client(
    with url: URL,
    headers: [String: String],
    additionalHeaders: @escaping () -> [String: String]
  ) -> ApolloClient {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = NetworkInterceptorProvider(store: store, additionalHeaders: additionalHeaders)
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url,
      additionalHeaders: headers
    )

    return ApolloClient(networkTransport: transport, store: store)
  }

  public func fetch<Query: GraphQLQuery>(query: Query) -> SignalProducer<Query.Data, ErrorEnvelope> {
    SignalProducer { observer, _ in
      self.fetch(query: query) { result in
        switch result {
        case let .success(response):
          guard let data = response.data else {
            return observer.send(error: .couldNotParseJSON) // FIXME: better error here (data is nil).
          }
          observer.send(value: data)
          observer.sendCompleted()
        case let .failure(error):
          observer.send(error: .couldNotDecodeJSON(error)) // FIXME: better error please.
        }
      }
    }
  }

  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation
  ) -> SignalProducer<Mutation.Data, ErrorEnvelope> {
    SignalProducer { observer, _ in
      self.perform(mutation: mutation) { result in
        switch result {
        case let .success(response):
          guard let data = response.data else {
            return observer.send(error: .couldNotParseJSON) // FIXME: better error here (data is nil).
          }
          observer.send(value: data)
          observer.sendCompleted()
        case let .failure(error):
          observer.send(error: .couldNotDecodeJSON(error)) // FIXME: better error please.
        }
      }
    }
  }
}

// MARK: - NetworkInterceptorProvider

class NetworkInterceptorProvider: LegacyInterceptorProvider {
  private let additionalHeaders: () -> [String: String]

  override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
    return [HeadersInterceptor(self.additionalHeaders)] + super.interceptors(for: operation)
  }

  init(store: ApolloStore, additionalHeaders: @escaping () -> [String: String]) {
    self.additionalHeaders = additionalHeaders
    super.init(store: store)
  }
}

// MARK: - HeadersInterceptor

class HeadersInterceptor: ApolloInterceptor {
  private let additionalHeaders: () -> [String: String]

  init(_ additionalHeaders: @escaping () -> [String: String]) {
    self.additionalHeaders = additionalHeaders
  }

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>
    ) -> Void
  ) {
    self.additionalHeaders().forEach(request.addHeader)

    chain.proceedAsync(
      request: request,
      response: response,
      completion: completion
    )
  }
}
