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
    static let toastSpacing: CGFloat = 8
    static let toastSlideInOffset: CGFloat = 80
    static let toastSlideInDuration: Double = 0.35
    static let toastSlideInDamping: CGFloat = 0.8
    static let toastSlideInVelocity: CGFloat = 0.5
    static let toastFadeOutDuration: Double = 0.2
    static let saveErrorToastAutoDismissDelay: Double = 3.0
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

  private var activeToasts: [UIView] = []
  private weak var videoErrorToastView: UIView?
  private weak var currentSaveErrorToastView: UIView?
  private var currentSaveErrorToastDismissWorkItem: DispatchWorkItem?

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
    self.resetToasts()
  }

  func pausePlayback() {
    self.videoPlayer.pause()
  }

  func resumePlayback() {
    guard self.playbackState.isPlaying else { return }
    self.videoPlayer.play()
  }

  // MARK: - Toast Layout

  private var toastOriginY: CGFloat {
    VideoFeedOverlayView.topSafeAreaPadding + VideoFeedOverlayView.closeButtonSize + Constants.toastTopGap
  }

  private var toastWidth: CGFloat {
    bounds.width - Constants.toastHorizontalPadding * 2
  }

  private func height(for toastView: UIView) -> CGFloat {
    toastView.systemLayoutSizeFitting(
      CGSize(width: self.toastWidth, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    ).height
  }

  private func relayoutToasts() {
    var nextToastOriginY = self.toastOriginY

    for activeToastView in self.activeToasts {
      let toastHeight = self.height(for: activeToastView)

      activeToastView.frame = CGRect(
        x: Constants.toastHorizontalPadding,
        y: nextToastOriginY,
        width: self.toastWidth,
        height: toastHeight
      )

      nextToastOriginY += toastHeight + Constants.toastSpacing
    }
  }

  // MARK: - Toast View

  private func resetToasts() {
    self.currentSaveErrorToastDismissWorkItem?.cancel()
    self.currentSaveErrorToastDismissWorkItem = nil
    self.currentSaveErrorToastView = nil
    self.videoErrorToastView = nil
    self.playbackState.hasSaveFailed = false
    self.activeToasts.forEach { $0.removeFromSuperview() }
    self.activeToasts.removeAll()
  }

  /// Adds a toast to the top of the `activeToasts` stack, pushing any existing toasts down.
  /// The toast slides in from above with a spring animation.
  private func insertToast(_ toastView: UIView) {
    /// Position off-screen above its final slot, ready to slide in
    toastView.frame = CGRect(
      x: Constants.toastHorizontalPadding,
      y: self.toastOriginY,
      width: self.toastWidth,
      height: self.height(for: toastView)
    )
    toastView.alpha = 0
    toastView.transform = CGAffineTransform(translationX: 0, y: -Constants.toastSlideInOffset)

    self.addSubview(toastView)
    self.activeToasts.insert(toastView, at: 0)

    /// Slide in the new toast and push any existing toasts down to make room
    UIView.animate(
      withDuration: Constants.toastSlideInDuration,
      delay: 0,
      usingSpringWithDamping: Constants.toastSlideInDamping,
      initialSpringVelocity: Constants.toastSlideInVelocity
    ) {
      toastView.alpha = 1
      toastView.transform = .identity

      self.relayoutToasts()
    }
  }

  // MARK: - Video Error Toast

  private func showVideoErrorToast() {
    let host = UIHostingController(rootView: VideoFeedToastView(message: Strings.Couldnt_load_video()))
    host.view.backgroundColor = .clear

    self.videoErrorToastView = host.view
    self.insertToast(host.view)
  }

  // MARK: - Save Error Toast

  func showSaveErrorToast() {
    self.playbackState.hasSaveFailed = true

    if let visibleSaveToast = self.currentSaveErrorToastView {
      self.scheduleSaveErrorToastDismissal(for: visibleSaveToast)
      return
    }

    let host = UIHostingController(
      rootView: VideoFeedToastView(message: Strings.Something_went_wrong_please_try_again())
    )
    host.view.backgroundColor = .clear

    let toastView = host.view!
    self.currentSaveErrorToastView = toastView
    self.insertToast(toastView)
    self.scheduleSaveErrorToastDismissal(for: toastView)
  }

  private func scheduleSaveErrorToastDismissal(for toastView: UIView) {
    self.currentSaveErrorToastDismissWorkItem?.cancel()

    let work = DispatchWorkItem { [weak self, weak toastView] in
      guard let self, let toastView else { return }

      self.dismissSaveErrorToast(toastView)
    }

    self.currentSaveErrorToastDismissWorkItem = work

    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.saveErrorToastAutoDismissDelay, execute: work)
  }

  private func dismissSaveErrorToast(_ toastView: UIView) {
    UIView.animate(
      withDuration: Constants.toastFadeOutDuration,
      animations: { toastView.alpha = 0 },
      completion: { _ in
        toastView.removeFromSuperview()
        self.activeToasts.removeAll { $0 === toastView }
        self.currentSaveErrorToastView = nil
        self.currentSaveErrorToastDismissWorkItem = nil

        UIView.animate(withDuration: Constants.toastSlideInDuration) {
          self.relayoutToasts()
        }

        if self.videoErrorToastView?.superview == nil {
          self.playbackState.hasSaveFailed = false
        }
      }
    )
  }

  // MARK: - Video Player View Setup

  private func setupVideoPlayerView() {
    self.videoPlayerView.frame = self.bounds
    self.videoPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.videoPlayerView.setPlayer(self.videoPlayer.player)
    self.insertSubview(self.videoPlayerView, belowSubview: self.contentView)
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
