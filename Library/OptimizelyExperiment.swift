import Foundation

public enum OptimizelyExperiment {
  public enum Key: String {
    case pledgeCTACopy = "pledge_cta_copy"
    case categoryPersonalization = "onboarding_category_personalization_flow"
  }

  public enum Variant: String, Equatable {
    case control
    case variant1 = "variant-1"
    case variant2 = "variant-2"
  }
}
