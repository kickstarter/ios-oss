import Foundation
@testable import Kickstarter_Framework

public struct MockQualtricsResultType: QualtricsResultType {
  var passedResult: Bool

  public func passed() -> Bool {
    return self.passedResult
  }
}
