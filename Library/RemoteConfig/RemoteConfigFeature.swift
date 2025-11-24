import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case bypassPledgeManagerDecisionPolicy = "bypass_pledge_manager_decision_policy"
  case editPledgeOverTimeEnabled = "edit_pledge_over_time"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
  case rewardShipmentTracking = "reward_shipment_tracking"
  case similarProjectsCarousel = "similar_projects_carousel"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .bypassPledgeManagerDecisionPolicy: return "Bypass Pledge Manager Decision Policy"
    case .editPledgeOverTimeEnabled: return "Edit Pledge Over Time"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    case .rewardShipmentTracking: return "Reward Shipment Tracking"
    case .similarProjectsCarousel: return "Similar Projects Carousel"
    }
  }
}
