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

  enum Event {
    case closeTapped
    case creatorTapped
    case shareTapped
    case moreTapped
    case ctaTapped
    case videoReady
    case videoFailed
    case pauseTapped
    case resumeTapped
    case progressBarTapped(Float)
  }

  var onEvent: ((Event) -> Void)?

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
    self.onEvent = nil
    self.currentItemId = nil
    self.resetToasts()
    self.playbackState.reset()
    self.videoPlayer.stop()
  }

  // MARK: - Configuration

  func configureWith(value _: VideoFeedItem) {}

  func configureWith(
    item: Binding<VideoFeedItem>,
    isSaved: Binding<Bool>
  ) {
    self.currentItemId = item.wrappedValue.id

    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(
        isSaved: isSaved,
        item: item,
        playbackState: self.playbackState,
        videoPlayer: self.videoPlayer,
        onCloseTapped: { [weak self] in self?.onEvent?(.closeTapped) },
        onCreatorTapped: { [weak self] in self?.onEvent?(.creatorTapped) },
        onShareTapped: { [weak self] in self?.onEvent?(.shareTapped) },
        onMoreTapped: { [weak self] in self?.onEvent?(.moreTapped) },
        onCTATapped: { [weak self] in self?.ctaTapped() },
        onProgressBarTapped: { [weak self] progress in self?.onEvent?(.progressBarTapped(progress)) }
      )
    }
    .margins(.all, 0)
  }

  func ctaTapped() {
    self.playbackState.pause()
    self.onEvent?(.ctaTapped)
  }

  // MARK: - Video Playback

  /// Buffers the video but does not start playback. Call `startPlayback()` once the cell is settled.
  func loadVideo(url: URL) {
    self.videoPlayer.load(url: url)
  }

  func startPlayback() {
    self.playbackState.resume()
  }

  func resetVideo() {
    self.videoPlayer.stop()
    self.playbackState.reset()
    self.resetToasts()
  }

  func pausePlayback() {
    self.playbackState.pause()
  }

  /// Duration of the current video in milliseconds
  var currentVideoDurationMs: Int? {
    guard let duration = self.videoPlayer.player.currentItem?.duration,
          duration.isNumeric,
          duration.seconds > 0
    else { return nil }
    return Int(duration.seconds * 1_000)
  }

  var watchTimeMs: Int {
    self.videoPlayer.watchTimeMs
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
      self.onEvent?(.videoReady)
    }

    self.videoPlayer.onVideoFailed = { [weak self] in
      guard let self else { return }
      self.playbackState.videoDidFail()
      self.showVideoErrorToast()
      self.onEvent?(.videoFailed)
    }
  }

  // MARK: - Tap Gesture

  private func setupTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
    tap.cancelsTouchesInView = false
    self.addGestureRecognizer(tap)
  }

  /// Tapping anywhere on the cell toggles playback.
  @objc private func cellTapped() {
    guard self.playbackState.isVideoReady else { return }

    if self.playbackState.isPlaying {
      self.playbackState.pause()
      self.onEvent?(.pauseTapped)
    } else {
      self.playbackState.resume()
      self.onEvent?(.resumeTapped)
    }
  }
}
