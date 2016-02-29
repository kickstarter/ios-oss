import Foundation
import Models
import KsApi
import ReactiveCocoa
import Result
import ReactiveExtensions
import Prelude

internal protocol ProjectViewModelType {
  var inputs: ProjectViewModelInputs { get }
  var outputs: ProjectViewModelOutputs { get }
  var errors: ProjectViewModelErrors { get }
}

internal final class ProjectViewModel : ProjectViewModelType, ProjectViewModelInputs, ProjectViewModelOutputs, ProjectViewModelErrors {
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

  private let (scrollData, scrollDataObserver) = Signal<(offset: CGPoint, size: CGSize, window: CGSize), NoError>.pipe()
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

    self.project = apiService.fetchProject(initialProject)
      .demoteErrors()
      .beginsWith(value: initialProject)
      .replayLazily(1)

    self.videoURL = self.project
      .flatMap { $0.video?.high }
      .flatMap { NSURL(string: $0) }
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
      .debounce(4.0, onScheduler: env.debounceScheduler)
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

