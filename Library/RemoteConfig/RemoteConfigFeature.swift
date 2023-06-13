import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case consentManagementDialogEnabled = "consent_management_dialog"
  case creatorDashboardHiddenEnabled = "creator_dashboard_hidden"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .creatorDashboardHiddenEnabled: return "Creator Dashboard Hidden"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    }
  }
}
