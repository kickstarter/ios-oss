import ReactiveCocoa
import Result
import Models

internal protocol HomeViewModelOutputs {
  /// Emits when the view becomes/resigns active state
  var isActive: Signal<Bool, NoError> { get }

  /// Emits an array of playlists that the user can browse from the home  menu
  var playlists: SignalProducer<[HomePlaylistViewModel], NoError> { get }

  /// Emits the video URL for the project that is currently playing
  var nowPlayingVideoUrl: SignalProducer<NSURL?, NoError> { get }

  /// Emits the name of the project that is currently playing.
  var nowPlayingProjectName: SignalProducer<String?, NoError> { get }

  /// Emits a project view model that should be opened fullscreen
  var selectProject: Signal<Project, NoError> { get }

  /// Emits a true/false value that indicates how important any overlayed interface is at this
  /// moment. One can use this to dim the UI if useful.
  var interfaceImportance: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the video should be playing or not.
  var videoIsPlaying: Signal<Bool, NoError> { get }
}
