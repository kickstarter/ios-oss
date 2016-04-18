import KsApi
import ReactiveCocoa
import Result
import Models
import Library

internal protocol HomePlaylistViewModelInputs {
  func playlist(playlist: Playlist)
}

internal protocol HomePlaylistViewModelOutputs {
  var title: Signal<String?, NoError> { get }
}

internal final class HomePlaylistViewModel: HomePlaylistViewModelInputs, HomePlaylistViewModelOutputs {

  private let playlistProperty = MutableProperty<Playlist?>(nil)
  internal func playlist(playlist: Playlist) {
    self.playlistProperty.value = playlist
  }

  internal let title: Signal<String?, NoError>

  var inputs: HomePlaylistViewModelInputs { return self }
  var outputs: HomePlaylistViewModelOutputs { return self }

  init() {
    self.title = self.playlistProperty.signal.ignoreNil()
      .map { playlist in
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
}
