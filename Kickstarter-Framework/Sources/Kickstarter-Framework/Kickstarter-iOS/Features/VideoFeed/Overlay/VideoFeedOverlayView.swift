import KDS
import Kingfisher
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
    static let playButtonSize: CGFloat = 62
    static let playIconSize: CGFloat = 33
    static let playIconOffset: CGFloat = 2
    static let playButtonOffset: CGFloat = -90
    static let closeButtonSize: CGFloat = 44
    static let previewFadeDuration: Double = 0.3
    /// Defining safa area values because `UIHostingConfiguration` returns 0 for safe area insets when in a collectionview.
    static let topSafeAreaPadding: CGFloat = 60
    static let bottomSafeAreaPadding: CGFloat = 37
  }

  let item: VideoFeedItem
  let playbackState: VideoFeedPlaybackState
  let videoPlayer: VideoFeedVideoPlayer

  var onCloseTapped: (() -> Void)?
  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  var body: some View {
    ZStack(alignment: .bottom) {
      self.topGradient
        .ignoresSafeArea()
        .accessibilityHidden(true)

      Button(action: { self.onCloseTapped?() }) {
        if let icon = Library.image(named: "video-feed-close-icon") {
          Image(uiImage: icon)
            .foregroundColor(Color(Colors.Icon.light.uiColor()))
            .frame(width: Constants.closeButtonSize, height: Constants.closeButtonSize)
        }
      }
      .padding(.leading, Constants.horizontalPadding)
      .padding(.top, Constants.topSafeAreaPadding)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .accessibilityLabel("FPO: Close")

      VStack(alignment: .trailing, spacing: Constants.railBottomSpacing) {
        VideoFeedRightRailView(
          item: self.item,
          onCreatorTapped: self.onCreatorTapped,
          onSaveTapped: self.onSaveTapped,
          onShareTapped: self.onShareTapped,
          onMoreTapped: self.onMoreTapped
        )

        VideoFeedBottomOverlayView(item: self.item, videoPlayer: self.videoPlayer)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.bottom, Constants.bottomPadding + Constants.bottomSafeAreaPadding)
      .background(alignment: .bottom) {
        self.bottomGradient
          .ignoresSafeArea()
          .accessibilityHidden(true)
      }
    }
    .overlay(alignment: .center) {
      self.playButton
        .offset(y: Constants.playButtonOffset)
    }
    .background {
      /// Preview image shown while the video loads.
      /// Fades out once `isVideoReady` becomes true.
      if let previewURL = self.item.videoPreviewImageURL {
        KFImage(previewURL)
          /// Loading indicator placeholder unril  the preview image is loads.
          .placeholder {
            ZStack {
              Color.black.ignoresSafeArea()

              ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(Colors.Icon.light.uiColor()))
                .frame(width: Constants.playButtonSize, height: Constants.playButtonSize)
                .background(FrostedGlassBackgroundView())
                .clipShape(Circle())
                .offset(y: Constants.playButtonOffset)
            }
          }
          .resizable()
          .scaledToFill()
          .ignoresSafeArea()
          .opacity(self.playbackState.isVideoReady ? 0 : 1)
          .animation(
            .easeInOut(duration: Constants.previewFadeDuration),
            value: self.playbackState.isVideoReady
          )
          .accessibilityHidden(true)
      }
    }
    .ignoresSafeArea()
  }

  // MARK: - Play Button

  @ViewBuilder
  private var playButton: some View {
    let icon = Library.image(named: "video-feed-play-icon")

    if let icon {
      Image(uiImage: icon)
        .resizable()
        .scaledToFit()
        .foregroundColor(Color(Colors.Icon.light.uiColor()))
        .offset(x: Constants.playIconOffset)
        .frame(width: Constants.playIconSize, height: Constants.playIconSize)
        /// Second, larger, frame to create the frosted glass ring.
        .frame(width: Constants.playButtonSize, height: Constants.playButtonSize)
        .background(FrostedGlassBackgroundView())
        .clipShape(Circle())
        /// Tapping the play button resumes playback and hides the button.
        .onTapGesture { self.playbackState.resume() }
        .opacity(self.playbackState.isPlayButtonVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.15), value: self.playbackState.isPlayButtonVisible)
        .accessibilityLabel("FPO: Play")
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
