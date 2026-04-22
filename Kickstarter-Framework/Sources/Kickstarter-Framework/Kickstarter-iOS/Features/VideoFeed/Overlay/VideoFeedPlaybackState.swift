import Foundation

/// Owns play/pause UI state for a single video feed cell.
@Observable
final class VideoFeedPlaybackState {
  private enum Constants {
    static let autoHideDelay: TimeInterval = 2.0
  }

  var isPlaying: Bool = false
  var isPlayPauseVisible: Bool = false

  /// Invalidates any pending auto-hide when showPlayPause() is called again before the timer finsihes.
  private var autoHideToken: UUID = UUID()

  func showPlayPause() {
    self.isPlayPauseVisible = true
    let token = UUID()

    self.autoHideToken = token

    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.autoHideDelay) { [weak self] in
      guard let self, self.autoHideToken == token else { return }

      self.isPlayPauseVisible = false
    }
  }

  func togglePlayPause() {
    self.isPlaying.toggle()
    self.showPlayPause()
  }
}
