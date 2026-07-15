import KDS
import Library
import SwiftUI

internal struct VideoFeedBannerView: View {
  private enum Constants {
    static let cardCornerRadius: CGFloat = Spacing.unit_02
    static let cardPadding: CGFloat = Spacing.unit_03

    static let rootStackSpacing: CGFloat = Spacing.unit_03
    static let textStackSpacing: CGFloat = Spacing.unit_02

    static let thumbnailWidth: CGFloat = 110
    static let thumbnailHeight: CGFloat = 100

    static let ctaCornerRadius: CGFloat = Spacing.unit_04
    static let ctaContentInsets = EdgeInsets(
      top: Spacing.unit_02,
      leading: Spacing.unit_03,
      bottom: Spacing.unit_02,
      trailing: Spacing.unit_03
    )
  }

  internal var onTryItNowTapped: (() -> Void)?

  @Bindable var state: VideoFeedBannerViewState

  var body: some View {
    HStack(alignment: .center, spacing: Constants.rootStackSpacing) {
      VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
        Text(Strings.try_our_new_discovery_mode())
          .font(Font(UIFont.ksr_headingLG()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
          .lineLimit(nil)

        Text(Strings.swipe_through_a_video_feed_tuning_your_recommendations_along_the_way())
          .font(Font(UIFont.ksr_bodySM()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))

        Button {
          self.onTryItNowTapped?()
        } label: {
          /// ProgressView has no intrinsic size, so we use the label as the layout anchor
          /// and swap the visible content on top via overlay.
          /// Without this the ProgressView's lack of intrinsic size causes the animation to stutter.
          Text(Strings.try_it_now())
            .font(Font(UIFont.ksr_bodyMD()))
            .hidden()
            .padding(Constants.ctaContentInsets)
            .background(Color.white)
            .cornerRadius(Constants.ctaCornerRadius)
            .overlay {
              if self.state.isLoading {
                ProgressView()
                  .progressViewStyle(.circular)
                  .tint(Color(Colors.Icon.dark.uiColor()))
                  .transition(.opacity.combined(with: .scale(scale: 0.8)))
              } else {
                Text(Strings.try_it_now())
                  .font(Font(UIFont.ksr_bodyMD()))
                  .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
                  .transition(.opacity.combined(with: .scale(scale: 0.8)))
              }
            }
        }
        .disabled(self.state.isLoading)
        .accessibilityLabel(Strings.try_it_now())
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)

      Image("video-feed-banner-thumbnail")
        .resizable()
        .scaledToFit()
        .frame(width: Constants.thumbnailWidth, height: Constants.thumbnailHeight)
        .accessibilityHidden(true)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, Constants.cardPadding)
    .padding(.horizontal, self.state.horizontalContentPadding)
    .background(Color(Colors.Background.Accent.Purple.banner.uiColor()))
    .cornerRadius(Constants.cardCornerRadius)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Strings.try_our_new_discovery_mode())
  }
}
