import Foundation

public struct VideoFeedItem: Hashable {
  public let id: String

  /// Main title shown in the bottom overlay.
  public let title: String

  /// Creator name shown in the bottom overlay.
  public let creator: String

  /// Creator avatar URL — used in the right rail's circular avatar button.
  public let creatorImageURL: URL?

  /// Stats text shown below the title.
  public let statsText: String

  /// Left pill label.
  public let categoryPillText: String

  /// Right pill label.
  public let secondaryPillText: String

  /// HLS video stream URL.
  public let videoURL: URL?

  /// Video thumbnail/preview image URL.
  public let videoPreviewImageURL: URL?

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }

  public static func == (lhs: VideoFeedItem, rhs: VideoFeedItem) -> Bool {
    lhs.id == rhs.id
  }
}
