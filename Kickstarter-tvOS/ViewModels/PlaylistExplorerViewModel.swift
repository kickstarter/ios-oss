import KsApi
import Library
import ReactiveCocoa
import Result
import Prelude

protocol PlaylistExplorerViewModelInputs {
  /// Call when a playlist is focsed.
  func focusPlaylist(playlist: Playlist)

  /// Call when a project is focused.
  func focusProject(project: Project)

  /// Call when the menu button is pressed
  func menuButtonPressed()
}

protocol PlaylistExplorerViewModelOutputs {
  /// Emits when playlists are loaded
  var playlists: SignalProducer<[Playlist], NoError> { get }

  /// Emits when projects are loaded for the focused playlist.
  var projects: Signal<[Project], NoError> { get }

  /// Emits when the playlists should be opened/closed
  var playlistsOpened: Signal<Bool, NoError> { get }

  /// Emits when the playlist explorer should be dismissed.
  var dismiss: Signal<(), NoError> { get }
}

protocol PlaylistExplorerViewModelType {
  var inputs: PlaylistExplorerViewModelInputs { get }
  var outputs: PlaylistExplorerViewModelOutputs { get }
}

final class PlaylistExplorerViewModel: PlaylistExplorerViewModelType,
PlaylistExplorerViewModelInputs, PlaylistExplorerViewModelOutputs {
  typealias Model = Playlist
  let playlist: Playlist

  let (focusedPlaylist, focusedPlaylistObserver) = Signal<Playlist, NoError>.pipe()
  func focusPlaylist(playlist: Playlist) {
    focusedPlaylistObserver.sendNext(playlist)
  }
  let (focusedProject, focusedProjectObserver) = Signal<Project, NoError>.pipe()
  func focusProject(project: Project) {
    focusedProjectObserver.sendNext(project)
  }
  let (menuButtonPressedSignal, menuButtonPressedObserver) = Signal<(), NoError>.pipe()
  func menuButtonPressed() {
    menuButtonPressedObserver.sendNext(())
  }
  var inputs: PlaylistExplorerViewModelInputs { return self }

  let (playlists, playlistsObserver) = SignalProducer<[Playlist], NoError>.buffer(1)
  let projects: Signal<[Project], NoError>
  let playlistsOpened: Signal<Bool, NoError>
  let dismiss: Signal<(), NoError>
  var outputs: PlaylistExplorerViewModelOutputs { return self }

  init(playlist: Playlist, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.playlist = playlist

    if let category = self.playlist.category {
      apiService.fetchCategories()
        .map { $0.categories }
        .demoteErrors()
        .uncollect()
        .filter { c in c.id == category.id || c.parentId == category.id }
        .map { c in Playlist.Category(c) }
        .collect()
        .start(self.playlistsObserver)
    } else {
      self.playlistsObserver.sendNext([
        Playlist.Featured,
        Playlist.Recommended,
        Playlist.Popular
        ])
      self.playlistsObserver.sendCompleted()
    }

    self.projects = self.focusedPlaylist
      .debounce(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
      .skipRepeats()
      .map { playlist in playlist.discoveryParams }
      .switchMap { params in apiService.fetchDiscovery(params: params)
        .map { $0.projects }
        .demoteErrors() }

    self.playlistsOpened = Signal.merge([
      self.focusedPlaylist.mapConst(true),
      self.focusedProject.mapConst(false),
      self.menuButtonPressedSignal.mapConst(true)
        .debounce(0.1, onScheduler: QueueScheduler.mainQueueScheduler)
      ])
      .skipRepeats()

    self.dismiss = self.playlistsOpened
      .combinePrevious()
      .map { $0.0 }
      .takeWhen(self.menuButtonPressedSignal)
      .filter(isTrue)
      .ignoreValues()
  }
}
