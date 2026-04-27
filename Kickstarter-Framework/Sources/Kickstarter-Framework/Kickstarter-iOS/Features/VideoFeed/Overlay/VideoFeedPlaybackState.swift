import Foundation

/// Playback UI state for a single video feed cell.
@Observable
final class VideoFeedPlaybackState {
  /// When false the play button is shown, prompting the user to resume.
  var isPlaying: Bool = true
  var isPlayButtonVisible: Bool = false

  /// Pauses playback and shows the play button.
  func pause() {
    self.isPlaying = false
    self.isPlayButtonVisible = true
  }

  /// Resumes playback and hides the play button.
  func resume() {
    self.isPlaying = true
    self.isPlayButtonVisible = false
  }
}
