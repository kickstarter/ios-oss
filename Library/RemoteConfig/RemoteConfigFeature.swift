import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case editPledgeOverTimeEnabled = "edit_pledge_over_time"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case onboardingFlow = "onboarding_flow"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
  case netNewBackersWebView = "net_new_backers_web_view"
  case newDesignSystem = "new_design_system"
  case rewardShipmentTracking = "reward_shipment_tracking"
  case similarProjectsCarousel = "similar_projects_carousel"
  case secretRewards = "secret_rewards"
  case searchFilterByLocation = "search_filter_by_location"
  case netNewBackersGoToPM = "net_new_backers_go_to_pm"
  case searchFilterByAmountRaised = "search_filter_by_amount_raised"
  case searchFilterByShowOnlyToggles = "search_filter_by_show_only_toggles"
  case searchFilterByGoal = "search_filter_by_goal"
  case searchNewEmptyState = "search_new_empty_state"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .editPledgeOverTimeEnabled: return "Edit Pledge Over Time"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .onboardingFlow: return "Onboarding Flow"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    case .netNewBackersWebView: return "Net New Backers Web View"
    case .newDesignSystem: return "New Design System"
    case .rewardShipmentTracking: return "Reward Shipment Tracking"
    case .similarProjectsCarousel: return "Similar Projects Carousel"
    case .secretRewards: return "Secret Rewards"
    case .searchFilterByLocation: return "Filter Search by Project Location"
    case .netNewBackersGoToPM: return "Net New Backers Go To PM"
    case .searchFilterByAmountRaised: return "Filter Search by Amount Raised"
    case .searchFilterByShowOnlyToggles: return "Filter Search by 'Show Only' Toggles"
    case .searchFilterByGoal: return "Filter Search by Goal"
    case .searchNewEmptyState: return "Use New Empty State In Search"
    }
  }
}
