import Foundation
import Library

internal struct MockOptimizelyResult: OptimizelyResultType {
  var shouldSucceed: Bool = true

  var hasError: Error? {
    return self.shouldSucceed ? nil : MockOptimizelyError.generic
  }
}
