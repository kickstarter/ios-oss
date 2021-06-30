import Apollo
@testable import KsApi
import XCTest

class ApolloInterceptorsTests: XCTestCase {
  func testInterceptor() {
    let headers = [
      "test-header-key-1": "test-header-value-1",
      "test-header-key-2": "test-header-value-2"
    ]
    let interceptor = HeadersInterceptor { headers }
    let query = MockApolloQuery()
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
      chain: RequestChain(interceptors: []),
      request: request,
      response: nil
    ) { _ in }

    XCTAssertEqual(request.additionalHeaders["test-header-key-1"], "test-header-value-1")
    XCTAssertEqual(request.additionalHeaders["test-header-key-2"], "test-header-value-2")
  }
}

// TODO: Move to shared mock file
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
