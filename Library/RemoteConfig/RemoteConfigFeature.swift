import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case blockUsersEnabled = "block_users"
  case consentManagementDialogEnabled = "consent_management_dialog"
  case darkModeEnabled = "dark_mode"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case reportThisProjectEnabled = "report_this_project"
  case loginWithOAuthEnabled = "ios_oauth"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .blockUsersEnabled: return "Block Users"
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .darkModeEnabled: return "Dark Mode"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .reportThisProjectEnabled: return "Report This Project"
    case .loginWithOAuthEnabled: return "Login with OAuth"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    }
  }
}
