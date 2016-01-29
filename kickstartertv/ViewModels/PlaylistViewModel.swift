import Darwin
import KsApi
import Models
import ReactiveCocoa

protocol PlaylistViewModelInputs {
  /// Call when a pan gesture ends with the distance the gesture traveled
  func swipeEnded(translation: CGPoint)

  /// Call when we should advance to the next playlist item.
  func nextPlaylistItem()

  /// Call when we should go to the previous playlist item.
  func previousPlaylistItem()

  /// Call with a boolean value when a transition begins/ends between two projects.
  func projectIsTransitioning(transitioning: Bool)

  /// Call when the playlist should change
  func changePlaylist(playlist: Playlist)
}

protocol PlaylistViewModelOutputs {
  /// Emits when a new project should be transitioned too
  var project: SignalProducer<Project, NoError> { get }
}

protocol PlaylistViewModelType {
  var inputs: PlaylistViewModelInputs { get }
  var outputs: PlaylistViewModelOutputs { get }
}

final class PlaylistViewModel : ViewModelType, PlaylistViewModelType, PlaylistViewModelInputs, PlaylistViewModelOutputs {
  typealias Model = Playlist

  // Inputs
  func swipeEnded(translation: CGPoint) {
    if translation.x < -1_100.0 {
      self.nextObserver.sendNext(())
    } else if translation.x > 1_100.0 {
      self.previousObserver.sendNext(())
    }
  }
  private let (next, nextObserver) = Signal<(), NoError>.pipe()
  func nextPlaylistItem() {
    self.nextObserver.sendNext(())
  }
  private let (previous, previousObserver) = Signal<(), NoError>.pipe()
  func previousPlaylistItem() {
    self.previousObserver.sendNext(())
  }
  private let (projectIsTransitioning, projectIsTransitioningObserver) = Signal<Bool, NoError>.pipe()
  func projectIsTransitioning(transitioning: Bool) {
    self.projectIsTransitioningObserver.sendNext(transitioning)
  }
  private let (playlist, playlistObserver) = Signal<Playlist, NoError>.pipe()
  func changePlaylist(playlist: Playlist) {
    self.playlistObserver.sendNext(playlist)
  }
  var inputs: PlaylistViewModelInputs { return self }

  // Outputs
  let (project, projectObserver) = SignalProducer<Project, NoError>.buffer(1)
  var outputs: PlaylistViewModelOutputs { return self }

  init(initialPlaylist: Playlist, currentProject: Project, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.projectObserver.sendNext(currentProject)
    next.mergeWith(previous)
      .map { _ in Int(arc4random_uniform(100_000)) }
      .switchMap { seed in
        return apiService.fetchProject(DiscoveryParams(staffPicks: true, hasVideo: true, state: .Live, seed: seed))
          .demoteErrors() }
      .observe(self.projectObserver)
  }
}
