import AVFoundation
import KDS
import Library
import SwiftUI
import UIKit

/// Hosts a `VideoFeedOverlayView` via UIHostingConfiguration and passes
/// right rail callbacks down so the controller can handle navigation.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  var onCloseTapped: (() -> Void)?
  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  /// Called once the video is ready to play. Used to unlock feed scrolling.
  var onVideoReady: (() -> Void)?
  /// Called when the video fails to load or play.
  var onVideoFailed: (() -> Void)?

  private let playbackState = VideoFeedPlaybackState()
  private let videoPlayer = VideoFeedVideoPlayer()
  private let videoPlayerView = VideoFeedPlayerView()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

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
    self.onSaveTapped = nil
    self.onShareTapped = nil
    self.onMoreTapped = nil
    self.onVideoReady = nil
    self.onVideoFailed = nil
    self.playbackState.reset()
    self.videoPlayer.stop()
  }

  // MARK: - Configuration

  func configureWith(value: VideoFeedItem) {
    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(
        item: value,
        playbackState: self.playbackState,
        videoPlayer: self.videoPlayer,
        onCloseTapped: { [weak self] in self?.onCloseTapped?() },
        onCreatorTapped: { [weak self] in self?.onCreatorTapped?() },
        onSaveTapped: { [weak self] in self?.onSaveTapped?() },
        onShareTapped: { [weak self] in self?.onShareTapped?() },
        onMoreTapped: { [weak self] in self?.onMoreTapped?() }
      )
    }
    .margins(.all, 0)
  }

  // MARK: - Video Playback

  func startPlayback(url: URL) {
    self.videoPlayer.load(url: url)
  }

  /// Loops video to start on `didEndDisplaying`
  func pauseAndReset() {
    self.videoPlayer.pause()
    self.videoPlayer.seek(to: 0)
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
