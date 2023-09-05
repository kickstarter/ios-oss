import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case consentManagementDialogEnabled = "consent_management_dialog"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
  case useOfAIProjectTab = "use_of_ai_project_tab"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    case .useOfAIProjectTab: return "Use of AI Project Tab"
    }
  }
}
