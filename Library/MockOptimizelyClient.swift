@testable import Library
import Optimizely

public class MockOptimizelyClient: OptimizelyClientType {
  var experimentalGroup = true

  public func activate(experimentKey: String, userId: String, attributes: OptimizelyAttributes?) throws
    -> String {
      if experimentalGroup == true {
        return "experimental"
      } else {
        return "control"
      }
  }

  public func variant(for experiment: OptimizelyExperiment.Key) -> String {
    if experimentalGroup == true {
      return "experimental"
    } else {
      return "control"
    }
  }

}
