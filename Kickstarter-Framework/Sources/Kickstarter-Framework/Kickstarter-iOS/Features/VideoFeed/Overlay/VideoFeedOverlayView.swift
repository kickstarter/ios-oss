import KDS
import SwiftUI

/// WIP: Full-screen SwiftUI Video Feed overlay. Currently Static.
/// Takes a plain VideoFeedItem.
struct VideoFeedOverlayView: View {
  private enum Constants {
    static let topGradientOverlayOpacity: Double = 0.2
    static let topGradientOverlayHeight: CGFloat = 300
    static let bottomGradientOverlayOpacity: Double = 0.55
    static let bottomGradientOverlayStartLocation: CGFloat = 0.1652
    static let bottomGradientOverlayEndLocation: CGFloat = 0.6957
    static let horizontalPadding: CGFloat = 14
    static let bottomPadding: CGFloat = 12
    static let railBottomSpacing: CGFloat = 20
  }

  let item: VideoFeedItem

  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  var body: some View {
    ZStack(alignment: .bottom) {
      self.topGradient
        .ignoresSafeArea()
        .accessibilityHidden(true)

      VStack(alignment: .trailing, spacing: Constants.railBottomSpacing) {
        VideoFeedRightRailView(
          item: self.item,
          onCreatorTapped: self.onCreatorTapped,
          onSaveTapped: self.onSaveTapped,
          onShareTapped: self.onShareTapped,
          onMoreTapped: self.onMoreTapped
        )
        .frame(maxWidth: .infinity, alignment: .trailing)

        VideoFeedBottomOverlayView(item: self.item)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.bottom, Constants.bottomPadding)
      .safeAreaPadding(.bottom)
      .background(alignment: .bottom) {
        self.bottomGradient
          .ignoresSafeArea()
          .accessibilityHidden(true)
      }
    }
    .safeAreaPadding(.top)
  }

  private var topGradient: some View {
    VStack(spacing: 0) {
      LinearGradient(
        colors: [.black.opacity(Constants.topGradientOverlayOpacity), .clear],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: Constants.topGradientOverlayHeight)

      Spacer()
    }
  }

  private var bottomGradient: some View {
    LinearGradient(
      stops: [
        .init(color: .clear, location: Constants.bottomGradientOverlayStartLocation),
        .init(
          color: .black.opacity(Constants.bottomGradientOverlayOpacity),
          location: Constants.bottomGradientOverlayEndLocation
        )
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}
