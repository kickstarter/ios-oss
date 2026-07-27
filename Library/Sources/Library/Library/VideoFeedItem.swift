import Foundation

public struct VideoFeedItem: Hashable {
  public let id: String

  public let pid: Int

  public let slug: String

  /// The project's web URL, used for the creator profile webview.
  public let projectURL: String

  /// Main title shown in the bottom overlay.
  public let title: String

  /// Creator name shown in the bottom overlay.
  public let creator: String

  /// Creator avatar URL for circular avatar button.
  public let creatorImageURL: URL?

  /// Stats text shown below the title.
  public let statsText: String

  /// Badges for this project (e.g. "Project We Love", "3 days left").
  public let badges: [Badge]

  /// HLS video stream URL.
  public let videoURL: URL?

  /// Video thumbnail/preview image URL.
  public let videoPreviewImageURL: URL?

  /// The GraphQL project ID used for watch/unwatch mutations.
  public let projectId: String

  /// Whether the current user has saved/watched this project.
  public var isSaved: Bool

  /// Number of times the project has been shared.
  public var sharesCount: Int

  /// Number of times the project has been watched (saved).
  public var watchesCount: Int

  /// Formatted watches (saves) count (e.g. "1.2k").
  public var formattedWatchesCount: String { Self.formattedCount(self.watchesCount) }

  /// Formatted shares count.
  public var formattedSharesCount: String { Self.formattedCount(self.sharesCount) }

  /// Percentage of funding goal reached. Can exceed 100 for overfunded projects.
  public let percentFunded: Int

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }

  public static func == (lhs: VideoFeedItem, rhs: VideoFeedItem) -> Bool {
    lhs.id == rhs.id
  }

  // MARK: - Private

  private static func formattedCount(_ count: Int) -> String {
    count.formatted(.number.notation(.compactName)).lowercased()
  }
}

// MARK: - Badge

extension VideoFeedItem {
  public struct Badge: Hashable {
    public let type: BadgeType
    public let text: String
    public let icon: String?
  }

  public enum BadgeType: Hashable {
    case projectWeLove
    case daysLeft
    case justLaunched
    case trending
    case unknown
  }
}
