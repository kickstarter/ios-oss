import ReactiveCocoa
import Result
import KsApi
import Models

protocol HomeViewModelInputs {
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

protocol HomeViewModelOutputs {
  /// Emits when the view becomes/resigns active state
  var isActive: Signal<Bool, NoError> { get }

  /// Emits an array of playlists that the user can browse from the home  menu
  var playlists: SignalProducer<[HomePlaylistViewModel], NoError> { get }

  /// Emits the playlist name, project name and video URL for the playlist that is beginning now.
  var nowPlayingInfo: Signal<(projectName: String, videoUrl: NSURL), NoError> { get }

  /// Emits a boolean to determine whether or not the overlayed UI should be displayed
  var overlayIsVisible: Signal<Bool, NoError> { get }

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
private typealias NowPlaying = (playlist: Playlist, project: Project)

final class HomeViewModel : HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {

  // MARK: Inputs
  func isActive(active: Bool) {
    isActiveObserver.sendNext(active)
  }

  private let (focusedPlaylist, focusedPlaylistObserver) = Signal<Playlist, NoError>.pipe()
  func focusedPlaylist(playlist: Playlist) {
    focusedPlaylistObserver.sendNext(playlist)
  }

  private let (startNextVideo, startNextVideoObserver) = Signal<Void, NoError>.pipe()
  func videoEnded() {
    startNextVideoObserver.sendNext(())
  }

  private let (clickedPlaylist, clickedPlaylistObserver) = Signal<Playlist, NoError>.pipe()
  func clickedPlaylist(playlist: Playlist) {
    clickedPlaylistObserver.sendNext(playlist)
  }

  private let (playVideoClickSignal, playVideoClickObserver) = Signal<(), NoError>.pipe()
  func playVideoClick() {
    playVideoClickObserver.sendNext(())
  }

  private let (pauseVideoClickSignal, pauseVideoClickObserver) = Signal<(), NoError>.pipe()
  func pauseVideoClick() {
    pauseVideoClickObserver.sendNext(())
  }

  var inputs: HomeViewModelInputs { return self }

  // MARK: Outputs
  let (isActive, isActiveObserver) = Signal<Bool, NoError>.pipe()
  let playlists: SignalProducer<[HomePlaylistViewModel], NoError>
  let nowPlayingInfo: Signal<(projectName: String, videoUrl: NSURL), NoError>
  let (overlayIsVisible, overlayIsVisibleObserver) = Signal<Bool, NoError>.pipe()
  let selectProject: Signal<Project, NoError>
  let (interfaceImportance, interfaceImportanceObserver) = Signal<Bool, NoError>.pipe()
  let (videoIsPlaying, videoIsPlayingObserver) = Signal<Bool, NoError>.pipe()
  var outputs: HomeViewModelOutputs { return self }

  init(env: Environment = AppEnvironment.current) {
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
    let nowPlaying: Signal<NowPlaying, NoError> = focusedPlaylist
      .debounce(1.0, onScheduler: env.debounceScheduler)
      .skipRepeats(==)
      .switchMap { playlist in
        apiService.fetchProject(playlist.discoveryParams)
          .map { (playlist, $0) }
          .demoteErrors()
      }

    self.nowPlayingInfo = nowPlaying
      .map { $0.project }
      .flatMap(HomeViewModel.nowPlayingInfo)

    self.selectProject = nowPlaying
      .takePairWhen(clickedPlaylist)
      .filter { nowPlaying, clickedPlaylist in
        nowPlaying.playlist == clickedPlaylist
      }
      .map { nowPlaying, _ in nowPlaying.project }

    Signal.merge([
        // UI is important the moment a playlist is focused or the video is paused
        self.focusedPlaylist.mapConst(true),
        self.pauseVideoClickSignal.mapConst(true),
        // UI is un-important the moment the video is played
        self.playVideoClickSignal.mapConst(false)
      ])
      .observe(self.interfaceImportanceObserver)

    // After a video is playing for awhile we can make the UI un-important
    self.focusedPlaylist
      .mapConst(false)
      .debounce(6.0, onScheduler: QueueScheduler.mainQueueScheduler)
      .withLatestFrom(videoIsPlaying)
      .filter { _, isPlaying in isPlaying }
      .map { importance, _ in importance }
      .observe(self.interfaceImportanceObserver)

    Signal.merge([
        self.playVideoClickSignal.mapConst(true),
        self.pauseVideoClickSignal.mapConst(false),
        nowPlaying.mapConst(true),
        self.isActive
      ])
      .observeNext { [weak self] in
        self?.videoIsPlayingObserver.sendNext($0)
    }
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
