import Foundation
import Library

internal struct MockOptimizelyResult: OptimizelyResultType {
  var shouldSucceed: Bool = true

  var isSuccess: Bool {
    return self.shouldSucceed
  }
}
