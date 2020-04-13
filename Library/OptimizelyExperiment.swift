import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Key: String {
    case nativeOnboarding = "native_onboarding_series_new_backers"
    case pledgeCTACopy = "pledge_cta_copy"
    case onboardingCategoryPersonalizationFlow = "onboarding_category_personalization_flow"
    case nativeProjectPageCampaignDetails = "native_project_page_campaign_details"
    case nativeProjectPageConversionCreatorDetails = "native_project_page_conversion_creator_details"
  }

  public enum Variant: String, Equatable {
    case control
    case variant1 = "variant-1"
    case variant2 = "variant-2"
  }
}

extension OptimizelyExperiment {
  static func projectCampaignExperiment(
    project: Project,
    refTag: RefTag?
  ) -> OptimizelyExperiment.Variant? {
    return AppEnvironment.current.optimizelyClient?
      .variant(
        for: OptimizelyExperiment.Key.nativeProjectPageCampaignDetails,
        userAttributes: optimizelyUserAttributes(with: project, refTag: refTag)
      )
  }
}
