import Foundation

public enum OptimizelyFeature: String, CaseIterable {
  case commentFlaggingEnabled = "ios_comment_threading_comment_flagging"
  case consentManagementDialogEnabled = "ios_consent_management_dialog"
  case facebookConversionsAPI = "ios_facebook_conversions_api"
  case facebookLoginDeprecationEnabled = "ios_facebook_deprecation"
  case projectPageStoryTabEnabled = "project_page_v2_story"
}

extension OptimizelyFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .commentFlaggingEnabled: return "Comment Flagging"
    case .consentManagementDialogEnabled: return "Consent Management Dialog"
    case .facebookConversionsAPI: return "Facebook Conversions API"
    case .facebookLoginDeprecationEnabled: return "Facebook Login Deprecation"
    case .projectPageStoryTabEnabled: return "Project Page Story Tab"
    }
  }
}
