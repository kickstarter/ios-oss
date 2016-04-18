import KsApi
import ReactiveCocoa
import Result
import Models
import Library

protocol PlaylistsMenuViewModelInputs {
  func playlist(playlist: Playlist)
  func selectProject(project: Project)
}

protocol PlaylistsMenuViewModelOutputs {
  var title: Signal<String, NoError> { get }
  var projects: Signal<[Project], NoError> { get }
  var selectedProjectAndPlaylist: Signal<(Project, Playlist), NoError> { get }
}

final class PlaylistsMenuViewModel: PlaylistsMenuViewModelInputs,
PlaylistsMenuViewModelOutputs {

  private let playlistProperty = MutableProperty<Playlist?>(nil)
  internal func playlist(playlist: Playlist) {
    self.playlistProperty.value = playlist
  }

  private let selectProjectProperty = MutableProperty<Project?>(nil)
  func selectProject(project: Project) {
    self.selectProjectProperty.value = project
  }

  var title: Signal<String, NoError>
  let projects: Signal<[Project], NoError>
  let selectedProjectAndPlaylist: Signal<(Project, Playlist), NoError>

  var inputs: PlaylistsMenuViewModelInputs { return self }
  var outputs: PlaylistsMenuViewModelOutputs { return self }

  init() {
    let playlist = self.playlistProperty.signal.ignoreNil()

    self.title = playlist.map(titleForPlaylist)

    self.projects = playlist.switchMap {
      AppEnvironment.current.apiService.fetchProjects($0.discoveryParams)
        .demoteErrors()
    }

    self.selectedProjectAndPlaylist = combineLatest(
      self.selectProjectProperty.signal.ignoreNil(),
      playlist
    )
  }
}

private func titleForPlaylist(playlist: Playlist) -> String {
  switch playlist {
  case .Featured:
    return "Featured"
  case .Recommended:
    return "Recommended"
  case .Popular:
    return "What’s popular now"
  case let .Category(category):
    return category.name
  case let .CategoryFeatured(category):
    return category.name
  }
}
