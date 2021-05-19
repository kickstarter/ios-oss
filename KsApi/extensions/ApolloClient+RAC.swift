//
//  ApolloClient+GraphQLClientType.swift
//  KsApi
//
//  Created by Justin Swart on 5/18/21.
//  Copyright © 2021 Kickstarter. All rights reserved.
//

import Apollo
import Foundation

extension ApolloClient {
  /**
   Creates an Apollo Client instance with the specified URL and headers.
   
   Note: this configuration matches the `ApolloClient`s own `init(url:)` initializer but
   allows us to pass in additional headers.

   - parameter url: The URL for the GraphQL endpoint.
   - parameter headers: Additional headers to configure each GraphQL request with.

   - returns: An `ApolloClient` instance.
   */
  static func client(with url: URL, headers: @escaping () -> [String: String]) -> ApolloClient {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = NetworkInterceptorProvider(store: store, headers: headers)
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url
    )

    return ApolloClient(networkTransport: transport, store: store)
  }
}

class NetworkInterceptorProvider: LegacyInterceptorProvider {
  private let headers: () -> [String: String]

  override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
    return [HeadersInterceptor(headers)] + super.interceptors(for: operation)
  }

  init(store: ApolloStore, headers: @escaping () -> [String: String]) {
    self.headers = headers
    super.init(store: store)
  }
}

class HeadersInterceptor: ApolloInterceptor {
  private let headers: () -> [String: String]

  init(_ headers: @escaping () -> [String: String]) {
    self.headers = headers
  }

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>
  ) -> Void) {
    let headers = self.headers()

    headers.forEach { key, value in request.addHeader(name: key, value: value) }

    chain.proceedAsync(
      request: request,
      response: response,
      completion: completion
    )
  }
}
