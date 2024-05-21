import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case consentManagementDialogEnabled = "consent_management_dialog"
  case darkModeEnabled = "dark_mode"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
  case postCampaignPledgeEnabled = "post_campaign_pledge"
  case loginWithOAuthEnabled = "ios_oauth"
  case useKeychainForOAuthToken = "use_keychain_for_oauth_token"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .darkModeEnabled: return "Dark Mode"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    case .postCampaignPledgeEnabled: return "Post Campaign Pledging"
    case .loginWithOAuthEnabled: return "Login with OAuth"
    case .useKeychainForOAuthToken: return "Use Keychain for OAuth token"
    }
  }
}
