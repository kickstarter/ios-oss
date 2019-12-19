import Foundation
import Library
import Optimizely

extension OptimizelyClient: OptimizelyClientType {}

extension OptimizelyResult: OptimizelyResultType {
  public var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }
}
