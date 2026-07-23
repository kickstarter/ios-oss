import Foundation

public enum StatsigFeature: String, CaseIterable {
  case projectStoryRichText = "project_story_rich_text"
  case videoFeed = "video_feed"
}

extension StatsigFeature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .projectStoryRichText: "Project Story Rich Text"
    case .videoFeed: "Video Feed"
    }
  }
}
