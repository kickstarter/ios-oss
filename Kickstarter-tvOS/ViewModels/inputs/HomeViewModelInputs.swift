import ReactiveCocoa

internal protocol HomeViewModelInputs {
  /// Call when the view becomes/resigns active state, e.g. viewDidAppear, viewWillDisappear
  func isActive(active: Bool)

  /// Call when a playlist row is focused in the UI.
  func focusedPlaylist(playlist: Playlist)

  /// Call when the currently playing video has ended.
  func videoEnded()

  /// Call when a playlist is hard-clicked
  func clickedPlaylist(playlist: Playlist)

  /// Call when the play button is clicked and the video is currently in paused state.
  func playVideoClick()

  /// Call when the play button is clicked and the video is currently in playing state.
  func pauseVideoClick()
}
