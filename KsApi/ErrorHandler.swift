import Foundation

public protocol ErrorHandler {
  /**
   Given a URL Response and data, this method will allow for custom error handling logic.

   - parameter blockResponse: An `HTTPURLResponse` object with response data from a request.
   - parameter data: Data` associated with the request
   */
  func handleError(blockResponse: HTTPURLResponse, and data: Data)
}
