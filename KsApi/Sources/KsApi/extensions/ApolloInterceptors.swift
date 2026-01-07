import Apollo
import ApolloAPI
import Foundation

/// This is based on `LegacyInterceptorProvider` from Apollo version 0.x.
/// See: http://www.github.com/apollographql/apollo-ios/blob/0.44.0/Sources/Apollo/InterceptorProvider.swift#L31-L72
/// That's provider is longer included in Apollo 1.x, but we want to continue to have the same
/// behavior. This could, potentailly, be cleaned up to remove unnecessary interceptors.
class NetworkInterceptorProvider: InterceptorProvider {
  private let additionalHeaders: () -> [String: String]
  private let client: URLSessionClient
  private let store: ApolloStore

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.
  public init(
    store: ApolloStore,
    additionalHeaders: @escaping () -> [String: String]
  ) {
    self.additionalHeaders = additionalHeaders
    self.client = URLSessionClient()
    self.store = store
  }

  deinit {
    self.client.invalidate()
  }

  func interceptors<Operation: GraphQLOperation>(for _: Operation) -> [any ApolloInterceptor] {
    return [
      HeadersInterceptor(self.additionalHeaders),
      MaxRetryInterceptor(),
      CacheReadInterceptor(store: self.store),
      NetworkFetchInterceptor(client: self.client),
      ResponseCodeInterceptor(),
      JSONResponseParsingInterceptor(),
      AutomaticPersistedQueryInterceptor(),
      CacheWriteInterceptor(store: self.store)
    ]
  }

  func additionalErrorInterceptor<Operation: GraphQLOperation>(for _: Operation) -> ApolloErrorInterceptor? {
    // FIXME: It would be useful to add some additional logging for failed queries here.
    return nil
  }
}

// MARK: - HeadersInterceptor

class HeadersInterceptor: ApolloInterceptor {
  let id: String

  private let additionalHeaders: () -> [String: String]

  init(_ additionalHeaders: @escaping () -> [String: String]) {
    self.additionalHeaders = additionalHeaders
    self.id = UUID().uuidString
  }

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (
      Swift.Result<GraphQLResult<Operation.Data>, Error>
    ) -> Void
  ) {
    self.additionalHeaders().forEach(request.addHeader)
    chain.proceedAsync(
      request: request,
      response: response,
      interceptor: self,
      completion: completion
    )
  }
}
