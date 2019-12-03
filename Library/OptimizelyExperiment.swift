import Foundation
import KsApi

public struct OptimizelyExperiment {
  public var variationKey: String

  public init(variationKey: String) {
    self.variationKey = variationKey
  }

  public func userIsInOptimizelyExperiment() -> Bool {
    if variationKey == "experimental" { return true } else { return false }
  }
}
