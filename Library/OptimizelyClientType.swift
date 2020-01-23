import Foundation

public protocol OptimizelyClientType: AnyObject {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
  func getVariationKey(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
}

extension OptimizelyClientType {
  public func variant(
    for experiment: OptimizelyExperiment.Key,
    userId: String,
    isAdmin: Bool
  ) -> OptimizelyExperiment.Variant {
    let variationString: String?
    if isAdmin {
      variationString = try? self.getVariationKey(
        experimentKey: experiment.rawValue, userId: userId, attributes: nil
      )
    } else {
      variationString = try? self.activate(
        experimentKey: experiment.rawValue, userId: userId, attributes: nil
      )
    }

    guard
      let variation = variationString,
      let variant = OptimizelyExperiment.Variant(rawValue: variation)
    else {
      return .control
    }

    return variant
  }
}
