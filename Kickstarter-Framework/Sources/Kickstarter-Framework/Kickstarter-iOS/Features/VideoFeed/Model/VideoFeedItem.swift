import Foundation

public struct VideoFeedItem {
  let id: String

  /// Main title shown in the bottom overlay.
  let title: String

  /// Creator name shown in the bottom overlay.
  let creator: String

  /// Creator avatar URL used in the right rail.
  let creatorImageURL: URL?

  /// Stats text shown below the title
  let statsText: String

  /// Left pill label
  let categoryPillText: String

  /// Right pill label
  let secondaryPillText: String

  /// CTA button label
  let ctaTitle: String
}
