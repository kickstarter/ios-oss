import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Key: String {
    case pledgeCTACopy = "pledge_cta_copy"
  }

  public enum Variant: String {
    case control
    case experimental
  }
}
