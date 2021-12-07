import Foundation

public enum OptimizelyFeature: String, CaseIterable {
  case commentFlaggingEnabled = "ios_comment_threading_comment_flagging"
  case navigationSelectorProjectPageEnabled = "project_page_v2"
  case projectPageStoryTabEnabled = "project_page_v2_story"
}

extension OptimizelyFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .commentFlaggingEnabled: return "Comment Flagging"
    case .navigationSelectorProjectPageEnabled: return "Project Page with Navigation Selector"
    case .projectPageStoryTabEnabled: return "Project Page Story Tab"
    }
  }
}
