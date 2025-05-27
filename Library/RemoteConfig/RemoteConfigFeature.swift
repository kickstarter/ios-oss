import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case darkModeEnabled = "dark_mode"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case onboardingFlow = "onboarding_flow"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
  case netNewBackersWebView = "net_new_backers_web_view"
  case newDesignSystem = "new_design_system"
  case rewardShipmentTracking = "reward_shipment_tracking"
  case similarProjectsCarousel = "similar_projects_carousel"
  case searchFilterByPercentRaised = "search_filter_by_percent_raised"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .darkModeEnabled: return "Dark Mode"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .onboardingFlow: return "Onboarding Flow"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    case .netNewBackersWebView: return "Net New Backers Web View"
    case .newDesignSystem: return "New Design System"
    case .rewardShipmentTracking: return "Reward Shipment Tracking"
    case .similarProjectsCarousel: return "Similar Projects Carousel"
    case .searchFilterByPercentRaised: return "Filter Search by Percent Raised"
    }
  }
}
