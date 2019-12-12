@testable import Library
import Optimizely

public class MockOptimizelyClient: OptimizelyClientType {
  var experimentalGroup = true

  public func activate(experimentKey _: String, userId _: String, attributes _: OptimizelyAttributes?) throws
    -> String {
    if self.experimentalGroup == true {
      return "experimental"
    } else {
      return "control"
    }
  }

  public func variant(for _: OptimizelyExperiment.Key) -> String {
    if self.experimentalGroup == true {
      return "experimental"
    } else {
      return "control"
    }
  }
}
