import Foundation

public protocol PerimeterXClientType: PerimeterXErrorHandler {
  /**
   Returns a dictionary of `[String: String]`, representing httpHeaders from Perimeter X.
   */
  func headers() -> [String: String]
}

public protocol PerimeterXErrorHandler {
  /**
   Verifies a URLs response and handles any errors with the Perimeter X SDK.

   - parameter blockResponse: An `HTTPURLResponse` object with response data from a request.
   - parameter data:           `Data` associated with the request.
   */
  func handleError(blockResponse: HTTPURLResponse, and data: Data)
}
