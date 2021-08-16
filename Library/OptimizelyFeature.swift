import Foundation

public enum OptimizelyFeature: String, CaseIterable {
  case commentFlaggingEnabled = "ios_comment_threading_comment_flagging"
}

extension OptimizelyFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .commentFlaggingEnabled: return "Comment Flagging"
    }
  }
}
