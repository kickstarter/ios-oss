import Apollo
import Foundation
import ReactiveSwift
import PerimeterX_SDK

extension ApolloClient: ErrorHandler {
  /**
   Handles error's in any third party SDK we provide to `ApolloClient`

   - parameter data: The `Data` contained in the reponse.
   - parameter response: The `URLResponse` that is returned.
   - parameter callback: The `PerimeterX_SDK.PerimeterXChallengeResult` that is evaluated if the response is handled by PerimeterX.

   - returns: Whether the error was handled or not.
   */
  public func handleResponse(data: Data, response: URLResponse) -> Bool {
                                            
    return PerimeterX.handleResponse(response: response, data: data, callback: nil)
  }
}
