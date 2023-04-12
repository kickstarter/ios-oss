import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Key: String, CaseIterable {
    case temp = ""
  }

  public enum Variant: String, Equatable {
    case control
    case variant1 = "variant-1"
    case variant2 = "variant-2"
  }
}
