import KDS
import Library
import SwiftUI

/// Bottom overlay content for the video feed cell.
/// Contains the pill badges, title, stats text, CTA button, video progress bar, and percent funded circle.
/// Used in `VideoFeedOverlayView`.
struct VideoFeedBottomOverlayView: View {
  private enum Constants {
    static let contentSpacing: CGFloat = 8
    static let pillRowSpacing: CGFloat = 8
    static let ctaTopPadding: CGFloat = 16
    static let progressTopPadding: CGFloat = 24
    static let progressBarHeight: CGFloat = 2
    static let statsTextOpacity: Double = 0.9
  }

  let item: VideoFeedItem
  let videoPlayer: VideoFeedVideoPlayer

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.contentSpacing) {
      self.pills

      HStack(alignment: .top, spacing: Constants.contentSpacing) {
        VStack(alignment: .leading, spacing: Constants.contentSpacing) {
          self.titleText
          self.statsText
        }

        Spacer()

        // TODO: Use the percentFunded value retreieved from the backend.
        FundedPercentageCircleView(fundedPercent: 1.0)
      }
      self.ctaButton
      self.progressBar
    }
  }

  // MARK: - Main Components

  private var pills: some View {
    HStack(spacing: Constants.pillRowSpacing) {
      FeedPillView(icon: "video-feed-category-icon", text: self.item.categoryPillText)
      FeedPillView(icon: "video-feed-clock-icon", text: self.item.secondaryPillText)
    }
    /// .combined so VoiceOver reads both pills as one element e.g. "Film, 23 days left".
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(self.item.categoryPillText), \(self.item.secondaryPillText)")
  }

  private var titleText: some View {
    Text(self.item.title)
      .font(Font(UIFont.ksr_headingLG()))
      .foregroundColor(Color(Colors.Text.light.uiColor()))
      .lineLimit(2)
      .accessibilityLabel(self.item.title)
      .accessibilityAddTraits(.isHeader)
  }

  private var statsText: some View {
    Text(self.item.statsText)
      .font(Font(UIFont.ksr_caption1()))
      .foregroundColor(Color(Colors.Text.light.uiColor()))
      .accessibilityLabel(self.item.statsText)
  }

  private var ctaButton: some View {
    Button(self.item.ctaTitle, action: {})
      .buttonStyle(CTAButtonStyle())
      .padding(.top, Constants.ctaTopPadding)
      .accessibilityLabel(self.item.ctaTitle)
      .accessibilityAddTraits(.isButton)
      .accessibilityHint(self.item.ctaTitle)
  }

  private var progressBar: some View {
    VideoFeedProgressBarView(player: self.videoPlayer)
      .padding(.top, Constants.progressTopPadding)
  }
}

/// Category and "days left" badges.
private struct FeedPillView: View {
  private enum Constants {
    static let iconSize: CGFloat = 16
    static let horizontalPadding: CGFloat = 10
    static let verticalPadding: CGFloat = 6
    static let iconSpacing: CGFloat = 6
    static let opacity: Double = 0.25
    static let cornerRadius: CGFloat = 8
    static let borderWidth: CGFloat = 1
  }

  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: Constants.iconSpacing) {
      if let icon = Library.image(named: self.icon) {
        Image(uiImage: icon)
          .resizable()
          .frame(width: Constants.iconSize, height: Constants.iconSize)
      }

      Text(self.text)
        .font(Font(UIFont.ksr_caption2()).bold())
        .foregroundColor(Color(Colors.Text.light.uiColor()))
    }
    .padding(.horizontal, Constants.horizontalPadding)
    .padding(.vertical, Constants.verticalPadding)
    .background(FrostedGlassBackgroundView().opacity(Constants.opacity))
    .overlay(
      RoundedRectangle(cornerRadius: Constants.cornerRadius)
        .strokeBorder(Color.white.opacity(Constants.opacity), lineWidth: Constants.borderWidth)
    )
    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
  }
}

private struct CTAButtonStyle: SwiftUI.ButtonStyle {
  private enum Constants {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let borderOpacity: Double = 0.9
    static let borderOpacityPressed: Double = 0.5
    static let pressedOpacity: Double = 0.8
  }

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(Font(UIFont.ksr_callout()))
      .foregroundColor(Color(Colors.Text.light.uiColor()))
      .frame(maxWidth: .infinity)
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.vertical, Constants.verticalPadding)
      .background(.clear)
      .overlay(
        Capsule()
          .strokeBorder(
            Color.white.opacity(
              configuration.isPressed ? Constants.borderOpacityPressed : Constants.borderOpacity
            ),
            lineWidth: Constants.borderWidth
          )
      )
      .clipShape(Capsule())
      .opacity(configuration.isPressed ? Constants.pressedOpacity : 1.0)
  }
}
