import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case consentManagementDialogEnabled = "consent_management_dialog"
  case creatorDashboardEnabled = "creator_dashboard"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .creatorDashboardEnabled: return "Creator Dashboard"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    }
  }
}
