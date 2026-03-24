import KDS
import SwiftUI

internal struct VideoFeedBannerView: View {
  private enum Constants {
    // TODO: Update with Video Feed Translations [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    static let title = "FPO: Try our new discovery mode"
    static let subtitle = "FPO: Swipe through a video feed, tuning your recommendations along the way."
    static let ctaTitle = "FPO: Try it now"

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

  var body: some View {
    HStack(alignment: .center, spacing: Constants.rootStackSpacing) {
      VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
        Text(Constants.title)
          .font(Font(UIFont.ksr_headingLG()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))

        Text(Constants.subtitle)
          .font(Font(UIFont.ksr_bodySM()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))

        Button(action: { self.onTryItNowTapped?() }) {
          Text(Constants.ctaTitle)
            .font(Font(UIFont.ksr_bodyMD()))
            .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
            .padding(Constants.ctaContentInsets)
            .background(Color.white)
            .cornerRadius(Constants.ctaCornerRadius)
        }
      }

      Image("video-feed-banner-thumbnail")
        .resizable()
        .scaledToFit()
        .frame(width: Constants.thumbnailWidth, height: Constants.thumbnailHeight)
    }
    .padding(Constants.cardPadding)
    .background(Color(Colors.Background.Accent.Purple.banner.uiColor()))
    .cornerRadius(Constants.cardCornerRadius)
  }
}
