import Foundation

public enum RemoteConfigFeature: String, CaseIterable {
  case consentManagementDialogEnabled = "consent_management_dialog"
  case creatorDashboardEnabled = "creator_dashboard"
  case facebookLoginInterstitialEnabled = "facebook_interstitial"
  case reportThisProjectEnabled = "report_this_project"
  case useOfAIProjectTab = "use_of_ai_project_tab"
}

extension RemoteConfigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .creatorDashboardEnabled: return "Creator Dashboard"
    case .facebookLoginInterstitialEnabled: return "Facebook Login Interstitial"
    case .reportThisProjectEnabled: return "Report This Project"
    case .useOfAIProjectTab: return "Use of AI Project Tab"
    }
  }
}
