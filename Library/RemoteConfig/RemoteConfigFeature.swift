import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case darkModeEnabled = "dark_mode"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
  case newDesignSystem = "new_design_system"
  case rewardShipmentTracking = "reward_shipment_tracking"
  case searchFilters = "search_filters"
  case similarProjectsCarousel = "similar_projects_carousel"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .darkModeEnabled: return "Dark Mode"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    case .newDesignSystem: return "New Design System"
    case .rewardShipmentTracking: return "Reward Shipment Tracking"
    case .searchFilters: return "Search: Sort and Filters"
    case .similarProjectsCarousel: return "Similar Projects Carousel"
    }
  }
}
