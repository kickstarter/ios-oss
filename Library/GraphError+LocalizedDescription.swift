import Foundation
import KsApi

public extension GraphError {
  var localizedDescription: String {
    switch self {
    case let .decodeError(responseError):
      return responseError.message
    default:
      return Strings.general_error_something_wrong()
    }
  }
}
