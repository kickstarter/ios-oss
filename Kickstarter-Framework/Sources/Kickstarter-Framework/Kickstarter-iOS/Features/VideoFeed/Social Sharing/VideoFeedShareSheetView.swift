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

    static let facebookAppIDKey = "FacebookAppID"
    static let facebookStoriesURLScheme = "facebook-stories://share"
    static let facebookStickerBackgroundImageKey = "com.facebook.sharedSticker.backgroundImage"
    static let facebookStickerAppIDKey = "com.facebook.sharedSticker.appID"
  }

  @SwiftUI.Environment(\.dismiss) private var dismiss

  let item: VideoFeedItem
  var onMoreTapped: (() -> Void)?

  @State private var destinations: [VideoFeedShareDestination] = VideoFeedShareDestination.available()

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

        self.appGrid
          .padding(.horizontal, Constants.horizontalPadding)
          .padding(.top, Constants.cardToGridSpacing)
          .padding(.bottom, Constants.gridBottomPadding)
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

  private func tapped(_ destination: VideoFeedShareDestination) {
    switch destination {
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

  // MARK: - Image sharing

  private func renderedPreviewCard() -> UIImage? {
    let thumbnailImage = self.item.videoPreviewImageURL.flatMap {
      KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: $0.absoluteString)
    }
    let screenWidth = UIScreen.main.bounds.width
    let storyHeight = screenWidth * 16 / 9

    let renderer = ImageRenderer(
      content: ZStack {
        Color(UIColor(coreColor: .green_04))

        VideoFeedSharePreviewCard(item: self.item) {
          if let thumbnailImage {
            Image(uiImage: thumbnailImage).resizable().scaledToFill()
          } else {
            Color.gray
          }
        }
        .padding(.horizontal, Constants.horizontalPadding)
      }
      .frame(width: screenWidth, height: storyHeight)
    )

    renderer.scale = UIScreen.main.scale

    return renderer.uiImage
  }

  private var topPresentedViewController: UIViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
      .flatMap {
        var vc = $0.rootViewController
        while let presented = vc?.presentedViewController { vc = presented }
        return vc
      }
  }

  private func shareToFacebookFeed() {
    guard let url = VideoFeedShareDestination.projectURL(for: self.item),
          let topVC = self.topPresentedViewController else { return }

    let content = ShareLinkContent()
    content.contentURL = url

    /// imported from FacebookShare SDK
    ShareDialog(viewController: topVC, content: content, delegate: nil).show()
  }

  private func shareToFacebookStories() {
    guard let imageData = self.renderedPreviewCard()?.pngData() else { return }

    let facebookAppID = Bundle.main.object(forInfoDictionaryKey: Constants.facebookAppIDKey) as? String ?? ""

    UIPasteboard.general.setItems(
      [[
        Constants.facebookStickerBackgroundImageKey: imageData,
        Constants.facebookStickerAppIDKey: facebookAppID
      ]],
      options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
    )

    self.dismiss()

    guard let url = URL(string: Constants.facebookStoriesURLScheme) else { return }

    UIApplication.shared.open(url)
  }

  private func shareToX() {}
}

// MARK: - VideoFeedSharePreviewCard

private struct VideoFeedSharePreviewCard<Thumbnail: View>: View {
  private enum Constants {
    static var kickstarterWordmarkAssetName: String { "share-kickstarter-wordmark" }
  }

  let item: VideoFeedItem
  @ViewBuilder let thumbnail: () -> Thumbnail

  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      Color.clear
        .aspectRatio(16 / 9, contentMode: .fit)
        .overlay(self.thumbnail())
        .clipped()

      VStack(alignment: .leading, spacing: 8) {
        Text(self.item.title)
          .font(Font(UIFont.ksr_subhead().bolded))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
          .lineLimit(2)

        Text(self.item.creator)
          .font(Font(UIFont.ksr_caption1()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
      }

      if let image = Library.image(named: Constants.kickstarterWordmarkAssetName) {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(12)
    .background(Color(Colors.Icon.light.uiColor()))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

// MARK: - ShareDestinationButton

private struct ShareDestinationButton: View {
  private enum Constants {
    static let iconSize: CGFloat = 28
    static let iconCircleSize: CGFloat = 56
    static let iconLabelSpacing: CGFloat = 6
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
          .fixedSize(horizontal: false, vertical: true)
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
