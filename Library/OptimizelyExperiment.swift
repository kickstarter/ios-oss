import Foundation

public enum OptimizelyExperiment {
  public enum Key: String {
    case pledgeCTACopy = "pledge_cta_copy"
  }

  public enum Variant: String, Equatable {
    case control
    case experimental
  }
}
