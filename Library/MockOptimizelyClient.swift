@testable import Library

public class MockOptimizelyClient: OptimizelyClientType {
  var experimentalGroup = true

  public func activate(experimentKey: String, userId: String, attributes: [String : Any?]?) throws -> String {
    if self.experimentalGroup == true {
      return "experimental"
    } else {
      return "control"
    }
  }
}
