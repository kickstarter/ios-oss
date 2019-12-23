import Foundation

public protocol OptimizelyClientType: AnyObject {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
}

extension OptimizelyClientType {
  public func variant(
    for experiment: OptimizelyExperiment.Key,
    userId: String
  ) -> OptimizelyExperiment.Variant {
    guard
      let variation = try? self.activate(experimentKey: experiment.rawValue, userId: userId, attributes: nil),
      let variant = OptimizelyExperiment.Variant(rawValue: variation)
    else {
      return .control
    }

    return variant
  }
}
