import KDS
import Library
import SwiftUI

/// WIP: Full-screen SwiftUI Video Feed overlay. Currently Static.
/// Takes a plain VideoFeedItem.
struct VideoFeedOverlayView: View {
  private enum Constants {
    static let topGradientOverlayOpacity: Double = 0.2
    static let topGradientOverlayHeight: CGFloat = 300
    static let bottomGradientOverlayOpacity: Double = 0.55
    static let bottomGradientOverlayStartLocation: CGFloat = 0.16
    static let bottomGradientOverlayEndLocation: CGFloat = 0.7
    static let horizontalPadding: CGFloat = 14
    static let bottomPadding: CGFloat = 12
    static let railBottomSpacing: CGFloat = 20
    static let playPauseButtonSize: CGFloat = 62
    static let playPauseIconSize: CGFloat = 33
    static let playIconOffset: CGFloat = 2
    static let playPauseButtonOffset: CGFloat = -90
  }

  let item: VideoFeedItem
  let playbackState: VideoFeedPlaybackState

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
    .overlay(alignment: .center) {
      self.playPauseButton
        .offset(y: Constants.playPauseButtonOffset)
    }
  }

  // MARK: - Play/Pause

  @ViewBuilder
  private var playPauseButton: some View {
    let icon = Library
      .image(named: self.playbackState.isPlaying ? "video-feed-clock-icon" : "video-feed-play-icon")

    if let icon {
      Image(uiImage: icon)
        .resizable()
        .scaledToFit()
        .foregroundColor(.white)
        .offset(x: self.playbackState.isPlaying ? 0 : Constants.playIconOffset)
        .frame(width: Constants.playPauseIconSize, height: Constants.playPauseIconSize)
        /// Second frame is larger to create the frosted glass ring.
        .frame(width: Constants.playPauseButtonSize, height: Constants.playPauseButtonSize)
        .background(FrostedGlassBackgroundView())
        .clipShape(Circle())
        .onTapGesture { self.playbackState.togglePlayPause() }
        .opacity(self.playbackState.isPlayPauseVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.15), value: self.playbackState.isPlayPauseVisible)
        .accessibilityLabel(self.playbackState.isPlaying ? "FPO: Pause" : "FPO: Play")
        .accessibilityAddTraits(.isButton)
    }
  }

  // MARK: - Gradients

  private var topGradient: some View {
    VStack(spacing: 0) {
      LinearGradient(
        colors: [Color(Colors.Icon.dark.uiColor()).opacity(Constants.topGradientOverlayOpacity), .clear],
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
          color: Color(Colors.Icon.dark.uiColor()).opacity(Constants.bottomGradientOverlayOpacity),
          location: Constants.bottomGradientOverlayEndLocation
        )
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}
