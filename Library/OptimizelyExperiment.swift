import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Key: String, CaseIterable {
    case nativeOnboarding = "native_onboarding_series_new_backers"
    case onboardingCategoryPersonalizationFlow = "onboarding_category_personalization_flow"
    case nativeProjectCards = "native_project_cards"
    case nativeRiskMessaging = "native_risk_messaging"
  }

  public enum Variant: String, Equatable {
    case control
    case variant1 = "variant-1"
    case variant2 = "variant-2"
  }
}

extension OptimizelyExperiment {
  // Returns variation via getVariation for native_project_cards experiment
  static func nativeProjectCardsExperimentVariant() -> OptimizelyExperiment.Variant {
    guard let optimizelyClient = AppEnvironment.current.optimizelyClient else {
      return .control
    }

    let variant = optimizelyClient.getVariation(for: OptimizelyExperiment.Key.nativeProjectCards.rawValue)

    return variant
  }
}
