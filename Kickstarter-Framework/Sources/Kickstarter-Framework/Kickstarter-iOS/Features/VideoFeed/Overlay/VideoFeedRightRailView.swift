import KDS
import Library
import SwiftUI

/// Used inside `VideoFeedOverlayView`.
/// Contains the creator avatar, save, share, and more (…) buttons.
struct VideoFeedRightRailView: View {
  private enum Constants {
    static let railSpacing: CGFloat = 20
    static let moreButtonSize: CGFloat = 44
    static let avatarSize: CGFloat = 44

    static let saveIconFilled = "video-feed-saved-filled-icon"
    static let saveIconOutline = "video-feed-saved-icon"
    static let shareIcon = "video-feed-share-icon"
    static let moreIcon = "video-feed-ellipsis-icon"
    static let avatarPlaceholderIcon = "avatar--placeholder"

    /// Accessibility
    static let creatorAccessibilityLabel = Strings.Creator()
    static let saveAccessibilityLabel = Strings.Save()
    static let shareAccessibilityLabel = Strings.Share()
    static let moreAccessibilityLabel = Strings.More_options()
  }

  let item: VideoFeedItem
  @Binding var isSaved: Bool

  var onCreatorTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  var body: some View {
    VStack(spacing: Constants.railSpacing) {
      self.creatorAvatar
      self.saveButton
      self.shareButton
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
    let iconName = self.isSaved ? Constants.saveIconFilled : Constants.saveIconOutline

    return RailButtonView(imageName: iconName, label: self.item.formattedWatchesCount) {
      self.isSaved.toggle()
    }
    .accessibilityLabel(Constants.saveAccessibilityLabel)
    .animation(.easeInOut(duration: 0.15), value: self.isSaved)
  }

  private var shareButton: some View {
    RailButtonView(imageName: Constants.shareIcon, label: self.item.formattedSharesCount) {
      self.onShareTapped?()
    }
    .accessibilityLabel(Constants.shareAccessibilityLabel)
  }

  // Currently hidden. Will be added in VideoFeed V2.
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
