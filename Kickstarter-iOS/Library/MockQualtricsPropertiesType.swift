import Foundation
@testable import Kickstarter_Framework

public class MockQualtricsPropertiesType: QualtricsPropertiesType {
  var values: [String: Double] = [:]

  public func setNumber(number: Double, for key: String) {
    self.values[key] = number
  }
}
