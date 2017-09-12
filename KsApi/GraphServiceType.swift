import Foundation
import Prelude
import ReactiveSwift

public enum GraphQLError: Error {
  case graphQLError(GraphError)
  case invalidJson(responseString: String?)
  case requestError(Error, URLResponse?)
  case emptyResponse(URLResponse?)
}

public protocol GraphQLServiceType: ServiceType {
  func fetch<A: Decodable>(query: NonEmptySet<Query>)
    -> SignalProducer<A, GraphQLError>
}

extension GraphQLServiceType {

  /**
   Prepares a URL request to be sent to the server.

   - parameter originalRequest: The request that should be prepared.
   - parameter queryString:     The GraphQL query string for the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forRequest originalRequest: URLRequest, queryString: String = "")
    -> URLRequest {

      var request = originalRequest
      guard let URL = request.url else {
        return originalRequest
      }

      request.httpBody = "query=\(queryString)".data(using: .utf8)

      // swiftlint:disable:next force_unwrapping
      let components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
      request.url = components.url
      request.allHTTPHeaderFields = self.defaultHeaders

      return request
  }

  /**
   Prepares a request to be sent to the server.

   - parameter URL:         The URL to turn into a request and prepare.
   - parameter method:      The HTTP verb to use for the request.
   - parameter queryString: The GraphQL query string for the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forURL url: URL, queryString: String = "")
    -> URLRequest {

      var request = URLRequest(url: url)
      request.httpMethod = Method.POST.rawValue
      return self.preparedRequest(forRequest: request, queryString: queryString)
  }
}

