import FBSDKShareKit
import KDS
import Kingfisher
import Library
import SwiftUI

struct VideoFeedShareSheetView: View {
  private enum Constants {
    static let horizontalPadding: CGFloat = 38
    static let gridColumns = 4
    static let gridSpacing: CGFloat = 24
    static let cardToGridSpacing: CGFloat = 47
    static let titleTopPadding: CGFloat = 20
    static let titleBottomPadding: CGFloat = 16
    static let gridBottomPadding: CGFloat = 32

    static let previewCornerRadius: CGFloat = 12
    static let previewPadding: CGFloat = 12
    static let previewItemSpacing: CGFloat = 32

    static let iconSize: CGFloat = 28
    static let iconCircleSize: CGFloat = 56
    static let iconLabelSpacing: CGFloat = 6

    static let linkCopiedAnimationName = "video-feed-copy-link-checkmark"
    static let linkCopiedAnimationSize: CGFloat = 32
    static let linkCopiedDismissDelay: TimeInterval = 2.5
  }

  private enum FacebookConstants {
    static let appIDKey = "FacebookAppID"
    static let storiesURLScheme = "facebook-stories://share"
    static let stickerBackgroundImageKey = "com.facebook.sharedSticker.backgroundImage"
    static let stickerAppIDKey = "com.facebook.sharedSticker.appID"
  }

  @SwiftUI.Environment(\.dismiss) private var dismiss

  let item: VideoFeedItem
  var onMoreTapped: (() -> Void)?
  var getPresentingViewController: (() -> UIViewController?)?

  @State private var destinations: [VideoFeedShareDestination] = VideoFeedShareDestination.available()
  @State private var linkCopied = false

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        Text(Strings.dashboard_accessibility_label_share_project())
          .font(Font(UIFont.ksr_headline()))
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .padding(.top, Constants.titleTopPadding)
          .padding(.bottom, Constants.titleBottomPadding)

        self.previewCard
          .padding(.horizontal, Constants.horizontalPadding)

        if self.linkCopied {
          self.linkCopiedConfirmation
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.cardToGridSpacing)
            .padding(.bottom, Constants.gridBottomPadding)
        } else {
          self.appGrid
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.cardToGridSpacing)
            .padding(.bottom, Constants.gridBottomPadding)
        }
      }
      .frame(width: geometry.size.width, alignment: .top)
    }
    .background {
      ZStack {
        Color(UIColor(coreColor: .green_04))
        Image(ImageResource.shareBackgroundSwirl)
          .resizable()
          .scaledToFill()
          .clipped()
      }
      .ignoresSafeArea()
    }
  }

  private var previewCard: some View {
    VideoFeedSharePreviewCard(item: self.item) {
      KFImage(self.item.videoPreviewImageURL)
        .resizable()
        .scaledToFill()
        .accessibilityHidden(true)
    }
  }

  private var appGrid: some View {
    LazyVGrid(
      columns: Array(
        repeating: GridItem(.flexible(), spacing: Constants.gridSpacing),
        count: Constants.gridColumns
      ),
      spacing: Constants.gridSpacing
    ) {
      ForEach(self.destinations) { destination in
        ShareDestinationButton(destination: destination) { [destination] in
          self.tapped(destination)
        }
      }
    }
  }

  private var linkCopiedConfirmation: some View {
    VStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(Color(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)))
          .frame(width: Constants.iconCircleSize, height: Constants.iconCircleSize)

        VideoFeedCopyLinkConfirmationView(animationName: Constants.linkCopiedAnimationName)
          .frame(width: Constants.linkCopiedAnimationSize, height: Constants.linkCopiedAnimationSize)
      }

      // TODO: Add translations
      Text("Link copied. Spread the word!")
        .font(Font(UIFont.ksr_subhead()))
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
  }

  private func tapped(_ destination: VideoFeedShareDestination) {
    switch destination {
    case .copyLink:
      self.copyLink()
    case .facebookFeed:
      self.shareToFacebookFeed()
    case .facebookStories:
      self.shareToFacebookStories()
    case .x:
      self.shareToX()
    case .more:
      self.dismiss()
      self.onMoreTapped?()
    default:
      destination.perform(item: self.item)
    }
  }

  // MARK: - Copy Link

  private func copyLink() {
    UIPasteboard.general.string = VideoFeedShareDestination.projectURL(for: self.item)?.absoluteString

    withAnimation { self.linkCopied = true }

    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.linkCopiedDismissDelay) {
      self.dismiss()
    }
  }

  // MARK: - Image Rendering

  func renderedPreviewCard() -> UIImage? {
    guard let previewURL = self.item.videoPreviewImageURL,
          let thumbnailImage = KingfisherManager.shared.cache
          .retrieveImageInMemoryCache(forKey: previewURL.absoluteString) else {
      return nil
    }

    let screenWidth = UIScreen.main.bounds.width
    let storyHeight = screenWidth * 16 / 9

    let renderer = ImageRenderer(
      content: ZStack {
        Color(UIColor(coreColor: .green_04))

        VideoFeedSharePreviewCard(item: self.item) {
          Image(uiImage: thumbnailImage).resizable().scaledToFill()
        }
        .padding(.horizontal, Constants.horizontalPadding)
      }
      .frame(width: screenWidth, height: storyHeight)
    )

    renderer.scale = UIScreen.main.scale

    return renderer.uiImage
  }

  // MARK: - Facebook Feed

  private func shareToFacebookFeed() {
    guard let url = VideoFeedShareDestination.projectURL(for: self.item),
          let presentingVC = self.getPresentingViewController?() else { return }

    let content = ShareLinkContent()
    content.contentURL = url

    /// imported from FacebookShare SDK
    ShareDialog(viewController: presentingVC, content: content, delegate: nil).show()
  }

  // MARK: - Facebook Stories

  private func shareToFacebookStories() {
    guard let imageData = self.renderedPreviewCard()?.pngData() else { return }

    guard let facebookAppID = Bundle.main.object(forInfoDictionaryKey: FacebookConstants.appIDKey) as? String
    else {
      assertionFailure("FacebookAppID is missing from Info.plist")
      return
    }

    UIPasteboard.general.setItems(
      [[
        FacebookConstants.stickerBackgroundImageKey: imageData,
        FacebookConstants.stickerAppIDKey: facebookAppID
      ]],
      options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
    )

    self.dismiss()

    guard let url = URL(string: FacebookConstants.storiesURLScheme) else { return }

    UIApplication.shared.open(url)
  }

  // MARK: - X

  private func shareToX() {}
}

// MARK: - ShareDestinationButton

private struct ShareDestinationButton: View {
  private enum Constants {
    static let iconSize: CGFloat = 28
    static let iconCircleSize: CGFloat = 56
    static let iconLabelSpacing: CGFloat = 6
    static let labelHeight: CGFloat = 28
  }

  let destination: VideoFeedShareDestination
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      VStack(spacing: Constants.iconLabelSpacing) {
        ZStack {
          Circle()
            .fill(Color.white)
            .frame(width: Constants.iconCircleSize, height: Constants.iconCircleSize)

          self.icon
        }

        Text(self.destination.label)
          .font(Font(UIFont.ksr_caption2()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .minimumScaleFactor(0.75)
          .frame(height: Constants.labelHeight, alignment: .top)
      }
    }
    .accessibilityLabel(self.destination.label)
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var icon: some View {
    if let image = Library.image(named: self.destination.iconAssetName) {
      Image(uiImage: image)
        .renderingMode(self.destination.usesDarkTint ? .template : .original)
        .resizable()
        .scaledToFit()
        .frame(width: self.destination.iconSize, height: self.destination.iconSize)
        .foregroundColor(self.destination.usesDarkTint ? Color(Colors.Icon.dark.uiColor()) : nil)
    } else {
      Image(systemName: self.destination.fallbackSystemIcon)
        .resizable()
        .scaledToFit()
        .frame(width: Constants.iconSize, height: Constants.iconSize)
        .foregroundColor(Color(Colors.Text.primary.uiColor()))
    }
  }
}

// MARK: - Fallback SF Symbols

extension VideoFeedShareDestination {
  var fallbackSystemIcon: String {
    switch self {
    case .copyLink: return "link"
    case .instagramFeed: return "camera"
    case .x: return "bird"
    case .instagramStories: return "camera.circle"
    case .facebookStories: return "f.circle"
    case .whatsApp: return "bubble.left.fill"
    case .facebookFeed: return "f.square"
    case .messages: return "message"
    case .email: return "envelope"
    case .more: return "ellipsis"
    }
  }
}
