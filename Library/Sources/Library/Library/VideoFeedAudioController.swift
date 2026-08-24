import AVFoundation

protocol AudioSessionManaging: AnyObject {
  func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode) throws
  func setActive(_ active: Bool) throws
  func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

final class LiveAudioSession: AudioSessionManaging {
  static let shared = LiveAudioSession()

  func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode) throws {
    try AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: [])
  }

  func setActive(_ active: Bool) throws {
    try AVAudioSession.sharedInstance().setActive(active)
  }

  func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
    try AVAudioSession.sharedInstance().setActive(active, options: options)
  }
}

// MARK: - Controller

/// Manages the AVAudioSession state machine for the video feed.
///
/// On iOS 26+, the session starts in `.soloAmbient` so the physical silent switch is respected.
/// When the user signals intent to hear audio (volume-up or the unmute overlay button), the session switches
/// to `.playback` to bypass the physical switch.
///
/// On iOS versions below 26, the session stays in `.playback` so that mute state is managed via the overlay button.
final class VideoFeedAudioController {
  private let session: AudioSessionManaging
  private(set) var isPlaybackSessionActive = false
  private(set) var isResettingAudioSession = false

  init(session: AudioSessionManaging = LiveAudioSession.shared) {
    self.session = session
  }

  func configure() {
    do {
      if #available(iOS 26, *) {
        try self.session.setCategory(.soloAmbient, mode: .default)
      } else {
        try self.session.setCategory(.playback, mode: .default)
      }
      try self.session.setActive(true)
    } catch {
      assertionFailure("VideoFeedAudioController: Failed to configure audio session: \(error)")
    }
  }

  /// Called when a volume-up press is detected.
  /// Switches to `.playback` to bypass the silent switch and marks the override as active.
  func handleVolumeUp() {
    guard !self.isResettingAudioSession else { return }

    self.activatePlayback()
  }

  /// Called when `outputMuteStateChangeNotification` fires (physical silent switch toggled).
  /// Resets the session to `.soloAmbient` so the switch takes effect.
  func handleSilentSwitchChange() {
    self.resetSession()
  }

  /// Called when the overlay mute button is tapped and the result is unmuted.
  /// Switches to `.playback` so the overlay can override the silent switch.
  func handleOverlayUnmute() {
    self.activatePlayback()
  }

  /// Called when a new video is activated.
  func handleNewVideoActivated() {
    if self.isPlaybackSessionActive {
      try? self.session.setCategory(.playback, mode: .default)
      try? self.session.setActive(true)
    } else {
      self.resetSession()
    }
  }

  /// Called on dismiss. Resets to `.soloAmbient` so the feed doesn't hold `.playback` after leaving.
  func handleDismiss() {
    try? self.session.setCategory(.soloAmbient, mode: .default)
  }

  // MARK: - Private

  private func activatePlayback() {
    try? self.session.setCategory(.playback, mode: .default)
    try? self.session.setActive(true)

    self.isPlaybackSessionActive = true
  }

  private func resetSession() {
    self.isResettingAudioSession = true
    self.isPlaybackSessionActive = false

    try? self.session.setActive(false, options: .notifyOthersOnDeactivation)
    try? self.session.setCategory(.soloAmbient, mode: .default)
    try? self.session.setActive(true)

    DispatchQueue.main.async {
      self.isResettingAudioSession = false
    }
  }
}
