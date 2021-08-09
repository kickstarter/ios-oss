import Apollo

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
