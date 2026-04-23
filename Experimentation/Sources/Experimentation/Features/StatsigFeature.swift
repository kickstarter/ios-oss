import Foundation

public enum StatsigFeature: String, CaseIterable {
  case videoFeed = "video_feed"
}

extension StatsigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .videoFeed: "Video Feed"
    }
  }
}
