import KsApi
import ReactiveCocoa
import Result
import Models

protocol PlaylistsMenuViewModelInputs {
  func selectProject(project: Project)
}

protocol PlaylistsMenuViewModelOutputs {
  var title: String { get }
  var projects: SignalProducer<[Project], NoError> { get }
  var selectedProjectAndPlaylist: Signal<(Project, Playlist), NoError> { get }
}

final class PlaylistsMenuViewModel : ViewModelType, PlaylistsMenuViewModelInputs, PlaylistsMenuViewModelOutputs {
  typealias Model = Playlist
  let playlist: Playlist

  // MARK: Inputs
  let (selectProject, selectProjectObserver) = Signal<Project, NoError>.pipe()
  func selectProject(project: Project) {
    selectProjectObserver.sendNext(project)
  }
  var inputs: PlaylistsMenuViewModelInputs { return self }

  // MARK: Outputs
  var title: String { return PlaylistsMenuViewModel.titleForPlaylist(playlist) }
  let projects: SignalProducer<[Project], NoError>
  let selectedProjectAndPlaylist: Signal<(Project, Playlist), NoError>
  var outputs: PlaylistsMenuViewModelOutputs { return self }

  convenience init(playlist: Playlist) {
    self.init(playlist: playlist, env: AppEnvironment.current)
  }

  init(playlist: Playlist, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.playlist = playlist

    self.projects = apiService.fetchProjects(self.playlist.discoveryParams)
      .demoteErrors()

    self.selectedProjectAndPlaylist = self.selectProject
      .map { ($0, playlist) }
  }

  private static func titleForPlaylist(playlist: Playlist) -> String {
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
}
