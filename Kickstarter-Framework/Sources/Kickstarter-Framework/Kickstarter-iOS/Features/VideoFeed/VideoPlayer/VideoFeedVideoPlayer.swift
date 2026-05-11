import AVFoundation
import AVKit
import Foundation

/// AVPlayer wrapper for a single video feed cell.
/// Loops by observing `AVPlayerItemDidPlayToEndTime` and seeking back to the start
@Observable
final class VideoFeedVideoPlayer {
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
  /// Once `onReady` has fired, flip this so we don't fire it repeatedly.
  private var hasFiredOnReady = false
  /// Same idea for `onVideoFailed` — only notify once per loaded item.
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
    print("`VideoFeedVideoPlayer`: Loading", url.absoluteString)

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

    /// Catches mid-playback failures (network drop, decoder error mid-stream).
    self.failedObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemFailedToPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] _ in
      self?.notifyFailed()
    }

    self.player.play()

    /// If we haven't started playing after 3s, log diagnostics and — if the item
    /// outright failed (e.g. unsupported codec) — surface that to the UI.
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
      guard let self, !self.hasFiredOnReady else { return }

      if let error = self.player.currentItem?.error {
        print("`VideoFeedVideoPlayer`: Item error:", error.localizedDescription)
        self.notifyFailed()
      } else if self.player.currentItem?.status == .failed {
        self.notifyFailed()
      } else {
        print(
          "`VideoFeedVideoPlayer`: Not playing after 3s. status:",
          self.player.currentItem?.status.rawValue ?? -1,
          "rate:", self.player.rate,
          "timeControlStatus:", self.player.timeControlStatus.rawValue
        )
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

  /// Fires `onVideoFailed` at most once per loaded item.
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
  }
}
