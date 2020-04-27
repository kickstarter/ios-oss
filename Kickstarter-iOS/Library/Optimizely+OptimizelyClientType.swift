import Foundation
import Library
import Optimizely

extension OptimizelyClient: OptimizelyClientType {}

extension OptimizelyResult: OptimizelyResultType {
  public var hasError: Error? {
    switch self {
    case .success:
      return nil
    case let .failure(error):
      return error
    }
  }
}

extension OptimizelyLogLevelType {
  public var logLevel: OptimizelyLogLevel {
    switch self {
    case .error:
      return OptimizelyLogLevel.error
    case .debug:
      return OptimizelyLogLevel.debug
    }
  }
}
