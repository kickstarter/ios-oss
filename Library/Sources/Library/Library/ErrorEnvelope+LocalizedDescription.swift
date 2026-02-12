import Foundation
import KsApi

public extension ErrorEnvelope {
  var localizedDescription: String {
    if let message = self.errorMessages.first {
      return message
    }

    return Strings.general_error_something_wrong()
  }
}
