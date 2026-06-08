import AVFoundation
import AVKit
import Foundation

/// AVPlayer wrapper for a single video feed cell.
/// Loops by observing `AVPlayerItemDidPlayToEndTime` and seeking back to the start
@Observable
class VideoFeedVideoPlayer {
  // MARK: - Outputs

  private(set) var progress: Double = 0

  var isPlaying: Bool { self.player.rate > 0 }
  let player = AVPlayer()
  var onVideoReady: (() -> Void)?
  /// Fired when the current item fails to load or play (e.g. an unsupported codec).
  var onVideoFailed: (() -> Void)?

  // MARK: - Private

  private var timeObserverToken: Any?
  private var endObserver: (any NSObjectProtocol)?
  private var failedObserver: (any NSObjectProtocol)?
  private var stalledObserver: (any NSObjectProtocol)?
  /// Once `onReady` has fired, flip this so we don't fire it repeatedly.
  private var hasFiredOnReady = false
  private var hasFiredOnFailed = false

  // MARK: - Lifecycle

  init() {
    self.addTimeObserver()
  }

  deinit {
    if let token = self.timeObserverToken {
      self.player.removeTimeObserver(token)
    }

    self.removeItemObservers()
  }

  /// Replaces the current item with the URL's content and starts playback.
  /// Loops on completion via `AVPlayerItemDidPlayToEndTime`.
  func load(url: URL) {
    self.hasFiredOnReady = false
    self.hasFiredOnFailed = false
    self.removeItemObservers()

    let item = AVPlayerItem(url: url)
    self.player.replaceCurrentItem(with: item)

    /// When this video ends, loop (seek) it back to the start.
    self.endObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] _ in
      self?.seek(to: 0) { _ in
        self?.player.play()
      }
    }

    /// Catches mid-playback failures (network drop, decoder errors, etc.).
    self.failedObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemFailedToPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] _ in
      self?.notifyFailed()
    }

    /// Catches errors caused by losing network connection mid-playback.
    /// AVPlayer triggers this when it can no longer load a video but doesn't transition to .failed it just freezes,
    /// `AVPlayerItemFailedToPlayToEndTime` never fires in this specific case.
    self.stalledObserver = NotificationCenter.default.addObserver(
      forName: AVPlayerItem.playbackStalledNotification,
      object: item,
      queue: .main
    ) { [weak self] _ in
      guard let self, self.player.currentItem === item else { return }

      /// Giving the player a 3s window to recover.
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
        guard let self,
              self.player.currentItem === item,
              self.player.rate == 0 else { return }

        self.notifyFailed()
      }
    }

    self.player.play()

    /// Fallback handler:
    /// if the item hasn't started playing after 3s, check if it failed and notify the UI.
    /// The `=== item` check guards against the cell being recycled before this fires.
    /// if it has, `currentItem` will have changed so we'll bail out.
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
      guard let self,
            self.player.currentItem === item,
            !self.hasFiredOnReady else { return }

      if self.player.currentItem?.error != nil || self.player.currentItem?.status == .failed {
        self.notifyFailed()
      }
    }
  }

  // MARK: - Playback control

  func play() {
    self.player.play()
  }

  func pause() {
    self.player.pause()
  }

  /// Tears down the current item. Used on cell reuse.
  func stop() {
    self.removeItemObservers()

    self.player.pause()
    self.player.replaceCurrentItem(with: nil)

    self.progress = 0

    self.hasFiredOnReady = false
    self.hasFiredOnFailed = false
  }

  func seek(to progress: Double, completion: ((Bool) -> Void)? = nil) {
    guard let duration = self.player.currentItem?.duration, duration.isNumeric else {
      completion?(false)
      return
    }

    let target = CMTime(
      seconds: progress * duration.seconds,
      preferredTimescale: CMTimeScale(NSEC_PER_SEC)
    )

    self.player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
      DispatchQueue.main.async {
        completion?(finished)
      }
    }
  }

  // MARK: - Private

  private func addTimeObserver() {
    let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    self.timeObserverToken = self.player.addPeriodicTimeObserver(
      forInterval: interval,
      queue: .main
    ) { [weak self] time in
      guard let self,
            let duration = self.player.currentItem?.duration,
            duration.isNumeric,
            duration.seconds > 0
      else { return }

      /// First non-zero tick means a frame is being presented so we can trigger `onReady`.
      if !self.hasFiredOnReady, time.seconds > 0 {
        self.hasFiredOnReady = true
        self.onVideoReady?()
      }

      self.progress = time.seconds / duration.seconds
    }
  }

  /// Guards against calling `onVideoFailed` more than once per video feed item..
  /// Both the `AVPlayerItemFailedToPlayToEndTime` notification and the failed to load timeout can observe the same failure.
  private func notifyFailed() {
    guard !self.hasFiredOnFailed else { return }

    self.hasFiredOnFailed = true
    self.onVideoFailed?()
  }

  private func removeItemObservers() {
    if let endObserver = self.endObserver {
      NotificationCenter.default.removeObserver(endObserver)
    }

    self.endObserver = nil

    if let failedObserver = self.failedObserver {
      NotificationCenter.default.removeObserver(failedObserver)
    }

    self.failedObserver = nil

    if let stalledObserver = self.stalledObserver {
      NotificationCenter.default.removeObserver(stalledObserver)
    }

    self.stalledObserver = nil
  }
}
