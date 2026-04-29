import Foundation

/// Stub Video Player
/// Publishes `progress` and `isPlaying` so `VideoFeedProgressBarView` scrubbing can be tested.
@Observable
final class VideoFeedVideoPlayer {
  private(set) var progress: Double = 0
  private(set) var isPlaying: Bool = false

  func play() {
    self.isPlaying = true
  }

  func pause() {
    self.isPlaying = false
  }

  func stop() {
    self.isPlaying = false
    self.progress = 0
  }

  func seek(to progress: Double, completion: ((Bool) -> Void)? = nil) {
    self.progress = progress

    completion?(true)
  }
}
