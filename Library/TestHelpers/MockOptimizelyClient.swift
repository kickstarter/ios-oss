import Library
import Kickstarter_Framework
import KsApi

public class MockOptimizelyClient: OptimizelyClientType {
  private(set) var experiments: [String: OptimizelyExperiment.Variant] = [:]

  public func activate(experimentKey: String, userId: String, attributes: [String : Any?]?) throws -> String {
    guard let experimentVariant = self.experiments[experimentKey] else {
      return Experiment.Variant.control.rawValue
    }

    return experimentVariant.rawValue
  }
}
