import AVFoundation
import KDS
import Library
import SwiftUI
import UIKit

/// # Component Structure
/// - `VideoFeedPlayerView` UIView backed by AVPlayerLayer, sits below the SwiftUI content view
/// - `VideoFeedVideoPlayer` AVPlayer wrapper, exposes `onVideoReady` / `onVideoFailed` callbacks
/// - `VideoFeedPlaybackState` observable UI state (isPlaying, isVideoReady, hasFailed)
/// - `VideoFeedOverlayView` SwiftUI overlay with gradients, right rail components, and bottom campaign info + CTA
///
/// # Playback flow
/// Loads video on `CollectionView.willDisplay`
/// After the first frame renders, we call `onVideoReady` +`playbackState.videoDidBecomeReady()`
/// Preview image fades out , video begins playback, and controller unlocks scrolling.
/// On `didEndDisplaying`, `clearVideo()` fully tears down the item so recycled cells don't keep buffering.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  var onCloseTapped: (() -> Void)?
  var onCreatorTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?
  var onCTATapped: (() -> Void)?

  /// Called once the video is ready to play. Used to unlock feed scrolling.
  var onVideoReady: (() -> Void)?
  /// Called when the video fails to load or play.
  var onVideoFailed: (() -> Void)?

  private let playbackState = VideoFeedPlaybackState()
  private let videoPlayer: VideoFeedVideoPlayer
  private let videoPlayerView = VideoFeedPlayerView()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    self.videoPlayer = VideoFeedVideoPlayer()

    super.init(frame: frame)

    self.commonInit()
  }

  init(frame: CGRect, videoPlayer: VideoFeedVideoPlayer) {
    self.videoPlayer = videoPlayer

    super.init(frame: frame)

    self.commonInit()
  }

  private func commonInit() {
    self.playbackState.videoPlayer = self.videoPlayer

    self.setupVideoPlayerView()
    self.setupVideoPlayerCallbacks()
    self.setupTapGesture()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.onCloseTapped = nil
    self.onCreatorTapped = nil
    self.onShareTapped = nil
    self.onMoreTapped = nil
    self.onCTATapped = nil
    self.onVideoReady = nil
    self.onVideoFailed = nil
    self.playbackState.reset()
    self.videoPlayer.stop()
  }

  // MARK: - Configuration

  func configureWith(value _: VideoFeedItem) {}

  func configureWith(
    value: VideoFeedItem,
    isSaved: Binding<Bool>
  ) {
    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(
        isSaved: isSaved,
        item: value,
        playbackState: self.playbackState,
        videoPlayer: self.videoPlayer,
        onCloseTapped: { [weak self] in self?.onCloseTapped?() },
        onCreatorTapped: { [weak self] in self?.onCreatorTapped?() },
        onShareTapped: { [weak self] in self?.onShareTapped?() },
        onMoreTapped: { [weak self] in self?.onMoreTapped?() },
        onCTATapped: { [weak self] in self?.ctaTapped() }
      )
    }
    .margins(.all, 0)
  }

  func ctaTapped() {
    self.pausePlayback()
    self.onCTATapped?()
  }

  // MARK: - Video Playback

  func loadVideo(url: URL) {
    self.videoPlayer.load(url: url)
  }

  func resetVideo() {
    self.videoPlayer.stop()
    self.playbackState.reset()
  }

  func pausePlayback() {
    self.videoPlayer.pause()
  }

  func resumePlayback() {
    guard self.playbackState.isPlaying else { return }

    self.videoPlayer.play()
  }

  // MARK: - Video Player View Setup

  private func setupVideoPlayerView() {
    self.videoPlayerView.frame = self.bounds
    self.videoPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.videoPlayerView.setPlayer(self.videoPlayer.player)
    /// Sits under the SwiftUI overlay so the overlay's gradients/buttons render on top of it.
    self.insertSubview(self.videoPlayerView, belowSubview: self.contentView)
  }

  /// Wires the player's ready/failed signals through to `self.playbackState`.
  private func setupVideoPlayerCallbacks() {
    self.videoPlayer.onVideoReady = { [weak self] in
      guard let self else { return }

      self.playbackState.videoDidBecomeReady()
      self.onVideoReady?()
    }

    self.videoPlayer.onVideoFailed = { [weak self] in
      guard let self else { return }

      self.playbackState.videoDidFail()
      self.onVideoFailed?()
    }
  }

  // MARK: - Tap gesture

  private func setupTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
    tap.cancelsTouchesInView = false

    self.addGestureRecognizer(tap)
  }

  /// Tapping anywhere on the cell pauses playback and shows the play button.
  /// Tapping the play button resumes playback and hides it.
  @objc private func cellTapped() {
    self.playbackState.pause()
  }
}
