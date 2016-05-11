import Foundation
import Models
import KsApi
import ReactiveCocoa
import Result
import ReactiveExtensions
import Prelude
import struct Library.Environment
import struct Library.AppEnvironment

internal protocol ProjectViewModelInputs {
  /// Call when the controller gains/resigns active state.
  func isActive(active: Bool)

  /// Call when the more playlists button is clicked
  func morePlaylistsClick()

  /// Call when the play/pause button is clicked
  func playPauseClicked(isPlay isPlay: Bool)

  /// Call with the newest content offset and size whenever it changes.
  func scrollChanged(offset offset: CGPoint, size: CGSize, window: CGSize)

  /// Call when there is some kind of user interaction with remote.
  func remoteInteraction()
}

internal protocol ProjectViewModelOutputs {
  /// Emits a project whenever it is updated
  var project: SignalProducer<Project, NoError> { get }

  /// Emits an array of recommendations
  var recommendations: SignalProducer<[Project], NoError> { get }

  /// Emits the most current video URL for the project.
  var videoURL: SignalProducer<NSURL, NoError> { get }

  /// Emits when the playlists explorer should be opened
  var openPlaylistsExplorer: Signal<Playlist, NoError> { get }

  /// Emits a boolean that determines if the video should play or not.
  var videoIsPlaying: Signal<Bool, NoError> { get }

  /// Emits a value between 0.0 and 1.0 that describes the timeline of how the video player
  /// should transition from fullscreen to picture-in-picture
  var videoTimelineProgress: Signal<CGFloat, NoError> { get }

  /// Emits a true/false value that indicates how important any overlayed interface is at this
  /// moment. One can use this to dim the UI if useful.
  var interfaceImportance: Signal<Bool, NoError> { get }
}

internal protocol ProjectViewModelErrors {
}

internal protocol ProjectViewModelType {
  var inputs: ProjectViewModelInputs { get }
  var outputs: ProjectViewModelOutputs { get }
  var errors: ProjectViewModelErrors { get }
}

internal final class ProjectViewModel: ProjectViewModelType, ProjectViewModelInputs, ProjectViewModelOutputs,
ProjectViewModelErrors {
  // MARK: Inputs
  private let (isActive, isActiveObserver) = Signal<Bool, NoError>.pipe()
  internal func isActive(active: Bool) {
    isActiveObserver.sendNext(active)
  }

  private let (morePlaylistsClickSignal, morePlaylistsClickObserver) = Signal<(), NoError>.pipe()
  internal func morePlaylistsClick() {
    morePlaylistsClickObserver.sendNext(())
  }

  internal func playPauseClicked(isPlay isPlay: Bool) {
    self.videoIsPlayingObserver.sendNext(isPlay)
  }

  private let (scrollData, scrollDataObserver) =
    Signal<(offset: CGPoint, size: CGSize, window: CGSize), NoError>.pipe()
  internal func scrollChanged(offset offset: CGPoint, size: CGSize, window: CGSize) {
    scrollDataObserver.sendNext((offset, size, window))
  }

  internal let (remoteInteractionSignal, remoteInteractionObserver) = Signal<(), NoError>.pipe()
  internal func remoteInteraction() {
    remoteInteractionObserver.sendNext(())
  }

  // MARK: Outputs
  internal let project: SignalProducer<Project, NoError>
  internal let recommendations: SignalProducer<[Project], NoError>
  internal let videoURL: SignalProducer<NSURL, NoError>
  internal let openPlaylistsExplorer: Signal<Playlist, NoError>
  internal let videoTimelineProgress: Signal<CGFloat, NoError>
  internal let (interfaceImportance, interfaceImportanceObserver) = Signal<Bool, NoError>.pipe()
  internal let (videoIsPlaying, videoIsPlayingObserver) = Signal<Bool, NoError>.pipe()

  internal var inputs: ProjectViewModelInputs { return self }
  internal var outputs: ProjectViewModelOutputs { return self }
  internal var errors: ProjectViewModelErrors { return self }

  internal init(project initialProject: Project, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.project = apiService.fetchProject(project: initialProject)
      .demoteErrors()
      .beginsWith(value: initialProject)
      .replayLazily(1)

    self.videoURL = self.project
      .map { $0.video?.high }
      .ignoreNil()
      .map { NSURL(string: $0) }
      .ignoreNil()
      .skipRepeats(==)

    self.recommendations = apiService.fetchProjects(
        DiscoveryParams(similarTo: initialProject, hasVideo: true)
      )
      .demoteErrors()

    self.openPlaylistsExplorer = self.morePlaylistsClickSignal
      .map { Playlist.Featured }

    self.videoTimelineProgress = self.scrollData
      .map(ProjectViewModel.ratioFromOffset)

    self.isActive.observe(self.interfaceImportanceObserver)

    Signal.merge([
        self.isActive,
        self.remoteInteractionSignal.mapConst(true)
      ])
      .observe(self.interfaceImportanceObserver)

    self.interfaceImportance
      .filter { $0 }
      .debounce(4.0, onScheduler: env.scheduler)
      .filterWhenLatestFrom(self.scrollData, satisfies: { $0.offset.y == 0.0 })
      .filterWhenLatestFrom(self.videoIsPlaying, satisfies: { $0 })
      .mapConst(false)
      .observe(self.interfaceImportanceObserver)

    self.isActive.observe(self.videoIsPlayingObserver)
  }

  private static func ratioFromOffset(offset: CGPoint, size: CGSize, window: CGSize) -> CGFloat {
    if size.height < window.height {
      return 0.0
    }
    return clamp(0.0, 1.0)(offset.y / (size.height - window.height))
  }
}
