import Foundation

public struct VideoFeedItem: Hashable {
  /// Unique identifier for diffable data source + player caching.
  let id: String

  /// Video URL to play for this feed item.
  let videoURL: URL

  /// Main title shown in the bottom overlay.
  let title: String

  /// Creator name shown in the bottom overlay.
  let creator: String

  /// Secondary stats text (can be empty in this spike).
  let statsText: String

  /// Small pill label text (category / tag).
  let categoryPillText: String

  /// CTA button label.
  let ctaTitle: String

  public func hash(into hasher: inout Hasher) {
    /// Hash by id so diffable updates are stable and predictable.
    hasher.combine(self.id)
  }

  public static func == (lhs: VideoFeedItem, rhs: VideoFeedItem) -> Bool {
    /// Equality matches hashing: items are the same if their ids match.
    lhs.id == rhs.id
  }
}
