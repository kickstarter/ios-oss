import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case darkModeEnabled = "dark_mode"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case pledgedProjectsOverviewEnabled = "pledged_projects_overview"
  case pledgedProjectsOverviewV2Enabled = "pledged_projects_overview_v2"
  case pledgeOverTime = "pledge_over_time"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .darkModeEnabled: return "Dark Mode"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .pledgedProjectsOverviewEnabled: return "Pledged Projects Overview"
    case .pledgedProjectsOverviewV2Enabled: return "Pledged Projects Overview V2"
    case .pledgeOverTime: return "Pledge Over Time"
    }
  }
}
