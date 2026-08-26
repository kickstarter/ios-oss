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
    VStack(alignment: .leading, spacing: Constants.previewItemSpacing) {
      Color.clear
        .aspectRatio(16 / 9, contentMode: .fit)
        .overlay(
          KFImage(self.item.videoPreviewImageURL)
            .resizable()
            .scaledToFill()
        )
        .clipped()
        .accessibilityHidden(true)

      /// Title + creator.
      VStack(alignment: .leading, spacing: 8) {
        Text(self.item.title)
          .font(Font(UIFont.ksr_subhead().bolded))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
          .lineLimit(2)

        Text(self.item.creator)
          .font(Font(UIFont.ksr_caption1()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
      }

      self.kickstarterBanner
    }
    .padding(Constants.previewPadding)
    .background(Color(Colors.Icon.light.uiColor()))
    .clipShape(RoundedRectangle(cornerRadius: Constants.previewCornerRadius))
  }

  @ViewBuilder
  private var kickstarterBanner: some View {
    if let image = Library.image(named: "share-kickstarter-wordmark") {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity, alignment: .leading)
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
    case .more:
      self.dismiss()
      self.onMoreTapped?()
    default:
      destination.perform(item: self.item)
    }
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
          .foregroundColor(.black)
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
