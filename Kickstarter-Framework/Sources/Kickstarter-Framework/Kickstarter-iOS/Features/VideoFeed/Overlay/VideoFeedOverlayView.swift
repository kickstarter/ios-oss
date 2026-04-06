import KDS
import SwiftUI

/// WIP: Full-screen SwiftUI Video Feed overlay. Currently Static.
/// Takes a plain VideoFeedItem.
struct VideoFeedOverlayView: View {
  private enum Constants {
    /// Gradient Overlay
    static let topGradientOverlayOpacity: Double = 0.2
    static let topGradientOverlayHeight: CGFloat = 300
    static let bottomGradientOverlayOpacity: Double = 0.55
    static let bottomGradientOverlayStartLocation: CGFloat = 0.1652
    static let bottomGradientOverlayEndLocation: CGFloat = 0.6957

    /// Layout
    static let horizontalPadding: CGFloat = 14
    static let bottomPadding: CGFloat = 12
    static let buttonFrame: CGFloat = 44
  }

  let item: VideoFeedItem

  var body: some View {
    ZStack(alignment: .bottom) {
      self.topGradient
        .ignoresSafeArea()
        /// Hidden so VoiceOver jumps straight to the interactive overlay.
        .accessibilityHidden(true)

      HStack(alignment: .bottom) {
        VideoFeedBottomOverlayView(item: self.item)
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.bottom, Constants.bottomPadding)
      .safeAreaPadding(.bottom)
      .frame(maxWidth: .infinity, alignment: .leading)
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
