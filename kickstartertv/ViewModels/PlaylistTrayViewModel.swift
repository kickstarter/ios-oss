import ReactiveCocoa
import Models
import KsApi

protocol PlaylistTrayViewModelInputs {
}

protocol PlaylistTrayViewModelOutputs {
  var playlists: SignalProducer<[Playlist], NoError> { get }
}

final class PlaylistTrayViewModel : ViewModelType, PlaylistTrayViewModelInputs, PlaylistTrayViewModelOutputs {
  typealias Model = Playlist

  var inputs: PlaylistTrayViewModelInputs { return self }

  let (playlists, playlistsObserver) = SignalProducer<[Playlist], NoError>.buffer(1)
  var outputs: PlaylistTrayViewModelOutputs { return self }

  init(playlist: Playlist) {
    playlistsObserver.sendNext([
      Playlist.Featured,
      Playlist.Popular,
      Playlist.Recommended,
    ])
  }
}
