import Kickstarter_Framework
import KsApi
import Library

internal struct OptimizelyError: Error {}

public class MockOptimizelyClient: OptimizelyClientType {
  var experiments: [String: String] = [:]
  var error: Error?

  public func activate(experimentKey: String, userId _: String, attributes _: [String: Any?]?) throws -> String {
    if let error = self.error {
      throw error
    }

    guard let experimentVariant = self.experiments[experimentKey] else {
      return Experiment.Variant.control.rawValue
    }

    return experimentVariant
  }
}
