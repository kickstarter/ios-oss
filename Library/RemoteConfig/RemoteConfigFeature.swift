import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case darkModeEnabled = "dark_mode"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case loginWithOAuthEnabled = "ios_oauth"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
  case pledgedProjectsOverviewEnabled = "pledged_projects_overview"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .darkModeEnabled: return "Dark Mode"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .loginWithOAuthEnabled: return "Login with OAuth"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    case .pledgedProjectsOverviewEnabled: return "Pledged Projects Overview"
    }
  }
}
