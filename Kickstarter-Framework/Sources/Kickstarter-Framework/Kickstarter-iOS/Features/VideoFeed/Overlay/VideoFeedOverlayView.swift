import KDS
import SwiftUI

/// WIP: Full-screen SwiftUI Video Feed overlay. Currently Static.
/// Takes a plain VideoFeedItem.
struct VideoFeedOverlayView: View {
  private enum Constants {
    /// Gradient Overlay
    static let topGradientOverlayOpacity: Double = 0.2
    static let topGradientOverlayHeight: CGFloat = 120
    static let bottomGradientOverlayHeight: CGFloat = 300
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
    ZStack {
      self.gradientOverlay.ignoresSafeArea()

      VStack {
        Spacer()

        HStack(alignment: .bottom) {
          VideoFeedBottomOverlayView(item: self.item)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.bottomPadding)
      }
      .safeAreaPadding(.top)
      .safeAreaPadding(.bottom)
    }
  }

  // MARK: - Sections

  private var gradientOverlay: some View {
    VStack(spacing: 0) {
      LinearGradient(
        colors: [.black.opacity(Constants.topGradientOverlayOpacity), .clear],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: Constants.topGradientOverlayHeight)

      Spacer()

      /// Stop positions match design spec: transparent at 16.52%, full opacity at 69.57%.
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
      .frame(height: Constants.bottomGradientOverlayHeight)
    }
  }
}
