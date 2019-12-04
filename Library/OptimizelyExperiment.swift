import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Variant: String {
  case control
  case experimental

    public init?(variationKey: String) {
      switch variationKey {
      case "control": self = .control
      case "experimental": self = .experimental
      default: return nil
      }
    }
  }
}
