import AVFoundation
import KDS
import Library
import SwiftUI
import UIKit

/// # Component Structure
/// - `VideoFeedPlayerView` UIView backed by AVPlayerLayer, sits below the SwiftUI content view
/// - `VideoFeedVideoPlayer` AVPlayer wrapper, exposes `onVideoReady` / `onVideoFailed` callbacks
/// - `VideoFeedPlaybackState` observable UI state (isPlaying, isVideoReady, hasFailed, hasSaveFailed)
/// - `VideoFeedOverlayView` SwiftUI overlay with gradients, right rail components, and bottom campaign info + CTA
///
/// # Playback flow
/// Loads video on `CollectionView.willDisplay`
/// After the first frame renders, we call `onVideoReady` + `playbackState.videoDidBecomeReady()`
/// Preview image fades out and video begins playback.
/// On `didEndDisplaying`, `resetVideo()` fully tears down the item so recycled cells don't keep buffering.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  private enum Constants {
    static let toastHorizontalPadding: CGFloat = 16
    static let toastTopGap: CGFloat = 8
  }

  var onCloseTapped: (() -> Void)?
  var onCreatorTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?
  var onCTATapped: (() -> Void)?
  /// Called once the video is ready to play.
  var onVideoReady: (() -> Void)?
  /// Called when the video fails to load or play.
  var onVideoFailed: (() -> Void)?

  private(set) var currentItemId: String?

  private let playbackState = VideoFeedPlaybackState()
  private let videoPlayer: VideoFeedVideoPlayer
  private let videoPlayerView = VideoFeedPlayerView()

  private lazy var toastContainerController: UIHostingController<VideoFeedToastContainerView> = {
    let controller = UIHostingController(rootView: VideoFeedToastContainerView())
    controller.view.backgroundColor = .clear
    return controller
  }()

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
    self.setupToastContainer()
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
    self.currentItemId = nil
    self.resetToasts()
    self.playbackState.reset()
    self.videoPlayer.stop()
  }

  // MARK: - Configuration

  func configureWith(value _: VideoFeedItem) {}

  func configureWith(
    value: VideoFeedItem,
    isSaved: Binding<Bool>
  ) {
    self.currentItemId = value.id

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
    self.playbackState.pause()
    self.onCTATapped?()
  }

  // MARK: - Video Playback

  /// Buffers the video but does not start playback. Call `startPlayback()` once the cell is settled.
  func loadVideo(url: URL) {
    self.videoPlayer.load(url: url)
  }

  func startPlayback() {
    self.videoPlayer.play()
  }

  func resetVideo() {
    self.videoPlayer.stop()
    self.playbackState.reset()
    self.resetToasts()
  }

  func pausePlayback() {
    self.videoPlayer.pause()
  }

  func resumePlayback() {
    guard self.playbackState.isPlaying else { return }
    self.videoPlayer.play()
  }

  // MARK: - Toast View

  private func resetToasts() {
    self.toastContainerController.rootView.videoErrorMessage = nil
    self.toastContainerController.rootView.saveErrorMessage = nil
    self.toastContainerController.rootView.onSaveErrorDismissed = nil
    self.playbackState.hasSaveFailed = false
  }

  // MARK: - Video Error Toast

  private func showVideoErrorToast() {
    self.toastContainerController.rootView.videoErrorMessage = Strings.Couldnt_load_video()
  }

  // MARK: - Save Error Toast

  func showSaveErrorToast() {
    self.playbackState.hasSaveFailed = true
    self.toastContainerController.rootView.saveErrorMessage = Strings
      .Something_went_wrong_please_try_again()

    self.toastContainerController.rootView.onSaveErrorDismissed = { [weak self] in
      guard let self else { return }

      self.toastContainerController.rootView.saveErrorMessage = nil

      if !self.toastContainerController.rootView.hasError {
        self.playbackState.hasSaveFailed = false
      }
    }
  }

  // MARK: - Video Player View Setup

  private func setupVideoPlayerView() {
    self.videoPlayerView.frame = self.bounds
    self.videoPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.videoPlayerView.setPlayer(self.videoPlayer.player)
    self.insertSubview(self.videoPlayerView, belowSubview: self.contentView)
  }

  private func setupToastContainer() {
    self.addSubview(self.toastContainerController.view)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    /// Position the container just below the close button and inset from the cell edges.
    let toastOriginY = VideoFeedOverlayView.topSafeAreaPadding + VideoFeedOverlayView
      .closeButtonSize + Constants.toastTopGap
    let toastWidth = self.bounds.width - Constants.toastHorizontalPadding * 2

    self.toastContainerController.view.frame = CGRect(
      x: Constants.toastHorizontalPadding,
      y: toastOriginY,
      width: toastWidth,
      height: 200
    )
  }

  private func setupVideoPlayerCallbacks() {
    self.videoPlayer.onVideoReady = { [weak self] in
      guard let self else { return }
      self.playbackState.videoDidBecomeReady()
      self.onVideoReady?()
    }

    self.videoPlayer.onVideoFailed = { [weak self] in
      guard let self else { return }
      self.playbackState.videoDidFail()
      self.showVideoErrorToast()
      self.onVideoFailed?()
    }
  }

  // MARK: - Tap Gesture

  private func setupTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
    tap.cancelsTouchesInView = false
    self.addGestureRecognizer(tap)
  }

  /// Tapping anywhere on the cell toggles playback:
  @objc private func cellTapped() {
    if self.playbackState.isPlaying {
      self.playbackState.pause()
    } else {
      self.playbackState.resume()
    }
  }
}
