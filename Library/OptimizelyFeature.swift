import Foundation

public enum OptimizelyFeature: String, CaseIterable {
  case commentFlaggingEnabled = "ios_comment_threading_comment_flagging"
  case facebookLoginDeprecationEnabled = "ios_facebook_deprecation"
  case paymentSheetEnabled = "ios_payment_sheet"
  case projectPageStoryTabEnabled = "project_page_v2_story"
  case rewardLocalPickupEnabled = "ios_local_pickup"
  case settingsPaymentSheetEnabled = "ios_settings_payment_sheet"
}

extension OptimizelyFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .commentFlaggingEnabled: return "Comment Flagging"
    case .facebookLoginDeprecationEnabled: return "Facebook Login Deprecation"
    case .paymentSheetEnabled: return "Payment Sheet"
    case .projectPageStoryTabEnabled: return "Project Page Story Tab"
    case .rewardLocalPickupEnabled: return "Local Pickup Rewards"
    case .settingsPaymentSheetEnabled: return "Settings Payment Sheet"
    }
  }
}
