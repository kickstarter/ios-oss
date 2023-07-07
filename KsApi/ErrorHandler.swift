import Foundation

public protocol ErrorHandler {
  /**
   Given a URL Response and data, this method will allow for custom error handling logic.

   - parameter response: An `URLResponse` object with response data from a request.
   - parameter data: `Data` associated with the request
   - parameter callback: `(Int) -> Void` Optional result of handling the request.

   - returns: A boolean indicating whether or not the error was handled.
   */
  func handleResponse(data: Data, response: URLResponse) -> Bool
}
