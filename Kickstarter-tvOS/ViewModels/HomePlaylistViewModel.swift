import KsApi
import ReactiveCocoa
import Models
import protocol Library.ViewModelType

protocol HomePlaylistViewModelOutputs {
  var title: String { get }
}

final class HomePlaylistViewModel: ViewModelType, HomePlaylistViewModelOutputs {
  typealias Model = Playlist
  let playlist: Playlist

  // MARK: Outputs
  let title: String
  var outputs: HomePlaylistViewModelOutputs { return self }

  init(playlist: Playlist) {
    self.playlist = playlist

    switch playlist {
    case .Featured:
      self.title = "Featured"
    case .Recommended:
      self.title = "Recommended"
    case .Popular:
      self.title = "What’s popular now"
    case let .Category(category):
      self.title = category.name
    case let .CategoryFeatured(category):
      self.title = category.name
    }
  }
}
