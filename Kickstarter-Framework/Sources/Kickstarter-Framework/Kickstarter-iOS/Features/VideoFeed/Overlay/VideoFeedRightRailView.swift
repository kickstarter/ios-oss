import KDS
import Library
import SwiftUI

/// Used inside `VideoFeedOverlayView`.
/// Contains the creator avatar, save, share, and more (…) buttons.
struct VideoFeedRightRailView: View {
  private enum Constants {
    static let railSpacing: CGFloat = 20
    static let moreButtonSize: CGFloat = 44
    static let saveCountLabel = "1k" // TODO: Replace with real save count from backend
    static let shareCountLabel = "50" // TODO: Replace with real share count from backend
    static let avatarSize: CGFloat = 44

    static let saveIcon = "video-feed-bookmark-icon"
    static let shareIcon = "video-feed-share-icon"
    static let moreIcon = "video-feed-ellipsis-icon"
    static let avatarPlaceholderIcon = "avatar--placeholder"

    /// Accessibility
    // TODO: Update with Video Feed Translations [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    static let creatorAccessibilityLabel = "FPO: Creator"
    static let saveAccessibilityLabel = "FPO: Save"
    static let shareAccessibilityLabel = "FPO: Share"
    static let moreAccessibilityLabel = "FPO: More"
  }

  let item: VideoFeedItem

  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  var body: some View {
    VStack(spacing: Constants.railSpacing) {
      self.creatorAvatar
      self.saveButton
      self.shareButton
      self.moreButton
    }
  }

  // MARK: - Buttons

  private var creatorAvatar: some View {
    Button(action: { self.onCreatorTapped?() }) {
      self.avatarPlaceholder
        .frame(width: Constants.avatarSize, height: Constants.avatarSize)
        .clipShape(Circle())
    }
    .accessibilityLabel(Constants.creatorAccessibilityLabel)
  }

  @ViewBuilder
  private var avatarPlaceholder: some View {
    if let image = Library.image(named: Constants.avatarPlaceholderIcon) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
    } else {
      Color(Colors.Text.placeholder.uiColor())
    }
  }

  private var saveButton: some View {
    RailButtonView(imageName: Constants.saveIcon, label: Constants.saveCountLabel) {
      self.onSaveTapped?()
    }
    .accessibilityLabel(Constants.saveAccessibilityLabel)
  }

  private var shareButton: some View {
    RailButtonView(imageName: Constants.shareIcon, label: Constants.shareCountLabel) {
      self.onShareTapped?()
    }
    .accessibilityLabel(Constants.shareAccessibilityLabel)
  }

  private var moreButton: some View {
    Button(action: { self.onMoreTapped?() }) {
      if let icon = Library.image(named: Constants.moreIcon) {
        Image(uiImage: icon)
          .foregroundColor(.white)
          .frame(width: Constants.moreButtonSize, height: Constants.moreButtonSize)
      }
    }
    .accessibilityLabel(Constants.moreAccessibilityLabel)
  }
}

// MARK: - RailButtonView

/// Icon + optional count label stacked vertically.
private struct RailButtonView: View {
  private enum Constants {
    static let buttonSize: CGFloat = 44
    static let labelSpacing: CGFloat = 4
  }

  let imageName: String
  let label: String
  let action: () -> Void

  var body: some View {
    VStack(spacing: Constants.labelSpacing) {
      Button(action: self.action) {
        if let icon = Library.image(named: self.imageName) {
          Image(uiImage: icon)
            .foregroundColor(.white)
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
        }
      }

      if !self.label.isEmpty {
        Text(self.label)
          .font(Font(UIFont.ksr_caption1()))
          .foregroundColor(Color(Colors.Text.light.uiColor()))
      }
    }
  }
}
