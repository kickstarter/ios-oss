import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case editPledgeOverTimeEnabled = "edit_pledge_over_time"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case onboardingFlow = "onboarding_flow"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
  case rewardShipmentTracking = "reward_shipment_tracking"
  case similarProjectsCarousel = "similar_projects_carousel"
  case secretRewards = "secret_rewards"
  case netNewBackersGoToPM = "net_new_backers_go_to_pm"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .editPledgeOverTimeEnabled: return "Edit Pledge Over Time"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .onboardingFlow: return "Onboarding Flow"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    case .rewardShipmentTracking: return "Reward Shipment Tracking"
    case .similarProjectsCarousel: return "Similar Projects Carousel"
    case .secretRewards: return "Secret Rewards"
    case .netNewBackersGoToPM: return "Net New Backers Go To PM"
    }
  }
}
