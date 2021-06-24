import Foundation

public enum OptimizelyFeature: String, CaseIterable {
  case commentFlaggingEnabled = "ios_comment_threading_comment_flagging"
  case commentThreading = "ios_comment_threading"
  case commentThreadingRepliesEnabled = "ios_comment_threading_reply_buttons"
}

extension OptimizelyFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .commentFlaggingEnabled: return "Comment Flagging"
    case .commentThreading: return "Comment Threading"
    case .commentThreadingRepliesEnabled: return "Comment Threading Replies"
    }
  }
}
