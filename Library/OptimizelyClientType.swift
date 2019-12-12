import Foundation
import Optimizely

public protocol OptimizelyClientType: class {
  func variant(for experiment: OptimizelyExperiment.Key) -> String
  func activate(experimentKey: String, userId: String, attributes: OptimizelyAttributes?) throws -> String
}

extension OptimizelyClient: OptimizelyClientType {
  public func variant(for experiment: OptimizelyExperiment.Key) -> String {
    return KSOptimizely.variant(for: experiment)
  }
}

