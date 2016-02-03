import ReactiveCocoa
import Result
import Models

internal protocol ProjectViewModelOutputs {
  /// Emits a project whenever it is updated
  var project: SignalProducer<Project, NoError> { get }

  /// Emits an array of recommendations
  var recommendations: SignalProducer<[Project], NoError> { get }

  /// Emits the most current video URL for the project.
  var videoURL: SignalProducer<NSURL, NoError> { get }

  /// Emits when the playlists explorer should be opened
  var openPlaylistsExplorer: Signal<Playlist, NoError> { get }

  /// Emits a boolean that determines if the video should play or not.
  var videoIsPlaying: Signal<Bool, NoError> { get }

  /// Emits a value between 0.0 and 1.0 that describes the timeline of how the video player
  /// should transition from fullscreen to picture-in-picture
  var videoTimelineProgress: Signal<CGFloat, NoError> { get }

  /// Emits a true/false value that indicates how important any overlayed interface is at this
  /// moment. One can use this to dim the UI if useful.
  var interfaceImportance: Signal<Bool, NoError> { get }
}
