import Apollo
import Foundation

class GraphQL {
  // MARK: - Properties

  private var apollo: ApolloClient?
  var client: ApolloClient {
    guard let client = self.apollo else {
      fatalError("Apollo Client accessed before calling configure(with:headers:additionalHeaders:)")
    }

    return client
  }

  static let shared = GraphQL()

  /**
   Configures the shared instance with the specified URL and headers.

   - parameter url: The URL for the GraphQL endpoint.
   - parameter headers: Additional headers to configure each GraphQL request with.
   */

  func configure(
    with url: URL,
    headers: [String: String],
    additionalHeaders: @escaping () -> [String: String]
  ) {
    let store = ApolloStore()
    let provider = NetworkInterceptorProvider(store: store, additionalHeaders: additionalHeaders)
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url,
      additionalHeaders: headers
    )

    self.apollo = ApolloClient(networkTransport: transport, store: store)
  }
}

extension ApolloClient {
  /**
   Creates an Apollo Client instance with the specified URL and headers.

   Note: this configuration matches the `ApolloClient`s own `init(url:)` initializer but
   allows us to pass in additional headers via instantiation and request interceptors.

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
}
