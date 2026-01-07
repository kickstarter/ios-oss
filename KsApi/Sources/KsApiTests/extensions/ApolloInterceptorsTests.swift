import Apollo
import GraphAPI
@testable import KsApi
import XCTest

class ApolloInterceptorsTests: XCTestCase {
  func testInterceptor() {
    let headers = [
      "test-header-key-1": "test-header-value-1",
      "test-header-key-2": "test-header-value-2"
    ]
    let interceptor = HeadersInterceptor { headers }
    // Any (concrete) query will do for this test -
    // just grabbed one off the top of my autocomplete.
    let query = GraphAPI.DefaultLocationsQuery(first: 1)
    let url = URL(string: "https://www.kickstarter.com")!
    let request = HTTPRequest(
      graphQLEndpoint: url,
      operation: query,
      contentType: "application/json",
      clientName: "client-name",
      clientVersion: "client-version",
      additionalHeaders: [:]
    )

    interceptor.interceptAsync(
      chain: InterceptorRequestChain(interceptors: []),
      request: request,
      response: nil
    ) { _ in }

    XCTAssertEqual(request.additionalHeaders["test-header-key-1"], "test-header-value-1")
    XCTAssertEqual(request.additionalHeaders["test-header-key-2"], "test-header-value-2")
  }
}
