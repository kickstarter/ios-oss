import ReactiveCocoa
import Result
import KsApi
import Models
import Prelude
import struct Library.Environment
import struct Library.AppEnvironment

protocol HomeViewModelType {
  var inputs: HomeViewModelInputs { get }
  var outputs: HomeViewModelOutputs { get }
}

/// A lightweight reference to a "now playing" playlist and project.
private struct NowPlaying {
  private let playlist: Playlist
  private let project: Project
}

internal final class HomeViewModel : HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {

  // MARK: Inputs
  internal func isActive(active: Bool) {
    isActiveObserver.sendNext(active)
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
  internal let (isActive, isActiveObserver) = Signal<Bool, NoError>.pipe()
  internal let playlists: SignalProducer<[HomePlaylistViewModel], NoError>
  internal let nowPlayingVideoUrl: SignalProducer<NSURL?, NoError>
  internal let nowPlayingProjectName: SignalProducer<String?, NoError>
  internal let selectProject: Signal<Project, NoError>
  internal let interfaceImportance: Signal<Bool, NoError>
  internal let videoIsPlaying: Signal<Bool, NoError>

  internal var inputs: HomeViewModelInputs { return self }
  internal var outputs: HomeViewModelOutputs { return self }

  internal init(env: Environment = AppEnvironment.current) {
    let scheduler = env.scheduler
    let apiService = env.apiService

    // Grab a playlist for every category
    self.playlists = apiService.fetchCategories().demoteErrors()
      .sort()
      .uncollect()
      .filter { $0.isRoot }
      .map(Playlist.CategoryFeatured)
      .beginsWith(values: [Playlist.Featured, Playlist.Recommended])
      .map(HomePlaylistViewModel.init)
      .collect()
      .replayLazily(1)

    // Derive the playlist and project that is now playing
    let nowPlaying = focusedPlaylist
      .debounce(1.0, onScheduler: scheduler)
      .skipRepeats(==)
      .switchMap { playlist in
        apiService.fetchProject(playlist.discoveryParams)
          .map { NowPlaying(playlist: playlist, project: $0) }
          .demoteErrors()
      }

    self.nowPlayingProjectName = SignalProducer(signal: nowPlaying)
      .map { $0.project.name }
      .wrapInOptional()
      .beginsWith(value: nil)

    self.nowPlayingVideoUrl = SignalProducer(signal: nowPlaying)
      .map { $0.project.video?.high }
      .ignoreNil()
      .map { NSURL(string: $0) }
      .beginsWith(value: nil)

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
      self.isActive
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

  /// Safely extracts project name and video URL from a project
  private static func nowPlayingInfo(project: Project) -> (projectName: String, url: NSURL)? {

    guard let
      urlString = project.video?.high,
      url = NSURL(string: urlString)
    else { return nil }

    return (project.name, url)
  }
}
