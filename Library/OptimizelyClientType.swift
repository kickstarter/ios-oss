import Foundation

public protocol OptimizelyClientType: AnyObject {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
}

extension OptimizelyClientType {
  public func variant(
    for experiment: OptimizelyExperiment.Key,
    userId: String
  ) -> OptimizelyExperiment.Variant {
    do {
      let variation = try self.activate(experimentKey: experiment.rawValue, userId: userId, attributes: nil)

      return OptimizelyExperiment.Variant(rawValue: variation) ?? .control
    } catch {
      return .control
    }
  }
}
