import ReactiveCocoa
import Result
import KsApi
import Models
import Prelude
import struct Library.Environment
import struct Library.AppEnvironment

internal protocol HomeViewModelInputs {
  func viewDidLoad()
  func viewWillAppear()
  func viewWillDisappear()

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

internal protocol HomeViewModelOutputs {
  /// Emits an array of playlists that the user can browse from the home  menu
  var playlists: Signal<[Playlist], NoError> { get }

  /// Emits the video URL for the project that is currently playing
  var nowPlayingVideoUrl: Signal<NSURL?, NoError> { get }

  /// Emits the name of the project that is currently playing.
  var nowPlayingProjectName: Signal<String?, NoError> { get }

  /// Emits a project view model that should be opened fullscreen
  var selectProject: Signal<Project, NoError> { get }

  /// Emits a true/false value that indicates how important any overlayed interface is at this
  /// moment. One can use this to dim the UI if useful.
  var interfaceImportance: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the video should be playing or not.
  var videoIsPlaying: Signal<Bool, NoError> { get }
}

protocol HomeViewModelType {
  var inputs: HomeViewModelInputs { get }
  var outputs: HomeViewModelOutputs { get }
}

/// A lightweight reference to a "now playing" playlist and project.
private struct NowPlaying {
  private let playlist: Playlist
  private let project: Project
}

internal final class HomeViewModel: HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {

  // MARK: Inputs
  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let viewWillAppearProperty = MutableProperty()
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let viewWillDisappearProperty = MutableProperty()
  internal func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  private let (focusedPlaylist, focusedPlaylistObserver) = Signal<Playlist, NoError>.pipe()
  internal func focusedPlaylist(playlist: Playlist) {
    focusedPlaylistObserver.sendNext(playlist)
  }

  private let (startNextVideo, startNextVideoObserver) = Signal<Void, NoError>.pipe()
  internal func videoEnded() {
    startNextVideoObserver.sendNext(())
  }

  private let (clickedPlaylist, clickedPlaylistObserver) = Signal<Playlist, NoError>.pipe()
  internal func clickedPlaylist(playlist: Playlist) {
    clickedPlaylistObserver.sendNext(playlist)
  }

  private let (playVideoClickSignal, playVideoClickObserver) = Signal<(), NoError>.pipe()
  internal func playVideoClick() {
    playVideoClickObserver.sendNext(())
  }

  private let (pauseVideoClickSignal, pauseVideoClickObserver) = Signal<(), NoError>.pipe()
  internal func pauseVideoClick() {
    pauseVideoClickObserver.sendNext(())
  }

  // MARK: Outputs
  internal let playlists: Signal<[Playlist], NoError>
  internal let nowPlayingVideoUrl: Signal<NSURL?, NoError>
  internal let nowPlayingProjectName: Signal<String?, NoError>
  internal let selectProject: Signal<Project, NoError>
  internal let interfaceImportance: Signal<Bool, NoError>
  internal let videoIsPlaying: Signal<Bool, NoError>

  internal var inputs: HomeViewModelInputs { return self }
  internal var outputs: HomeViewModelOutputs { return self }

  // swiftlint:disable function_body_length
  internal init(env: Environment = AppEnvironment.current) {
    let scheduler = env.scheduler
    let apiService = env.apiService

    // Grab a playlist for every category
    self.playlists = self.viewDidLoadProperty.signal
      .switchMap {
        apiService.fetchCategories()
          .sort()
          .uncollect()
          .filter { $0.isRoot }
          .map(Playlist.CategoryFeatured)
          .collect()
          .demoteErrors()
      }

    // Derive the playlist and project that is now playing
    let nowPlaying = focusedPlaylist
      .debounce(1.0, onScheduler: scheduler)
      .skipRepeats(==)
      .switchMap { playlist in
        apiService.fetchProject(playlist.discoveryParams)
          .map { NowPlaying(playlist: playlist, project: $0) }
          .demoteErrors()
      }

    self.nowPlayingProjectName = Signal.merge(
      nowPlaying.map { $0.project.name },
      self.viewDidLoadProperty.signal.mapConst(nil)
    )

    self.nowPlayingVideoUrl = nowPlaying
      .map { $0.project.video?.high }
      .ignoreNil()
      .map { NSURL(string: $0) }

    self.selectProject = nowPlaying
      .takePairWhen(clickedPlaylist)
      .filter { nowPlaying, clickedPlaylist in
        nowPlaying.playlist == clickedPlaylist
      }
      .map { nowPlaying, _ in nowPlaying.project }

    self.videoIsPlaying = Signal.merge([
      self.playVideoClickSignal.mapConst(true),
      self.pauseVideoClickSignal.mapConst(false),
      nowPlaying.mapConst(true),
      self.viewWillAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    ])

    // A signal that emits when the playlist has been focused for a little while
    let hasFocusedPlaylistForWhile = self.focusedPlaylist
      .debounce(6.0, onScheduler: scheduler)
      .filterWhenLatestFrom(videoIsPlaying, satisfies: id)

    // Control the interface importance by a few controls.
    self.interfaceImportance = Signal.merge([
        hasFocusedPlaylistForWhile.mapConst(false),
        self.focusedPlaylist.mapConst(true),
        self.pauseVideoClickSignal.mapConst(true),
        self.playVideoClickSignal.mapConst(false)
      ])
      .skipRepeats()
  }
  // swiftlint:enable function_body_length
}
