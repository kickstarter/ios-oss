import Foundation
import KsApi

public enum OptimizelyExperiment {
  public enum Key: String {
    case nativeOnboarding = "native_onboarding_series_new_backers"
    case pledgeCTACopy = "pledge_cta_copy"
    case nativeProjectPageCampaignDetails = "native_project_page_campaign_details"
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
    let userAttributes = optimizelyUserAttributes(
      with: AppEnvironment.current.currentUser,
      project: project,
      refTag: refTag
    )

    let optimizelyVariant = AppEnvironment.current.optimizelyClient?
      .variant(
        for: OptimizelyExperiment.Key.nativeProjectPageCampaignDetails,
        userId: deviceIdentifier(uuid: UUID()),
        isAdmin: AppEnvironment.current.currentUser?.isAdmin ?? false,
        userAttributes: userAttributes
      )

    return optimizelyVariant
  }
}
