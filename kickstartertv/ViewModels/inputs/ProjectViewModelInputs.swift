import CoreGraphics

internal protocol ProjectViewModelInputs {
  /// Call when the controller gains/resigns active state.
  func isActive(active: Bool)

  /// Call when the save button is clicked
  func saveClick()

  /// Call when the more playlists button is clicked
  func morePlaylistsClick()

  /// Call when the play/pause button is clicked
  func playPauseClicked(isPlay isPlay: Bool)

  /// Call with the newest content offset and size whenever it changes.
  func scrollChanged(offset offset: CGPoint, size: CGSize, window: CGSize)

  /// Call when there is some kind of user interaction with remote.
  func remoteInteraction()
}
