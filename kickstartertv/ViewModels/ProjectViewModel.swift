import Foundation
import Models
import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Prelude

protocol ProjectViewModelInputs {
  /// Call when the controller gains/resigns active state.
  func isActive(active: Bool)

  /// Call when the save button is clicked
  func saveClick()

  /// Call when the more playlists button is clicked
  func morePlaylistsClick()

  /// Call when the play/pause button is clicked
  func playPauseClicked(isPlay isPlay: Bool)

  /// Call with the newest content offset and size whenever it changes.
  func scrollChanged(offset offset: CGPoint, size: CGSize, window: CGSize)

  /// Call when there is some kind of user interaction with remote.
  func remoteInteraction()
}

protocol ProjectViewModelOutputs {
  /// Emits a project whenever it is updated
  var project: SignalProducer<Project, NoError> { get }

  /// Emits an array of recommendations
  var recommendations: SignalProducer<[Project], NoError> { get }

  /// Emits when we should show a successful save alert.
  var saveAlert: Signal<(), NoError> { get }

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

protocol ProjectViewModelErrors {
  /// Emits when user tries to save without being logged in.
  var savingRequiresLogin: Signal<(), NoError> { get }
}

protocol ProjectViewModelType {
  var inputs: ProjectViewModelInputs { get }
  var outputs: ProjectViewModelOutputs { get }
  var errors: ProjectViewModelErrors { get }
}

final class ProjectViewModel : ProjectViewModelType, ProjectViewModelInputs, ProjectViewModelOutputs, ProjectViewModelErrors {
  // MARK: Inputs
  private let (isActive, isActiveObserver) = Signal<Bool, NoError>.pipe()
  func isActive(active: Bool) {
    isActiveObserver.sendNext(active)
  }

  private let saveObserver: Observer<(), NoError>
  func saveClick() {
    saveObserver.sendNext(())
  }

  private let (morePlaylistsClickSignal, morePlaylistsClickObserver) = Signal<(), NoError>.pipe()
  func morePlaylistsClick() {
    morePlaylistsClickObserver.sendNext(())
  }

  func playPauseClicked(isPlay isPlay: Bool) {
    self.videoIsPlayingObserver.sendNext(isPlay)
  }

  private let (scrollData, scrollDataObserver) = Signal<(offset: CGPoint, size: CGSize, window: CGSize), NoError>.pipe()
  func scrollChanged(offset offset: CGPoint, size: CGSize, window: CGSize) {
    scrollDataObserver.sendNext((offset, size, window))
  }

  let (remoteInteractionSignal, remoteInteractionObserver) = Signal<(), NoError>.pipe()
  func remoteInteraction() {
    remoteInteractionObserver.sendNext(())
  }

  var inputs: ProjectViewModelInputs { return self }

  // MARK: Outputs
  let (project, projectObserver) = SignalProducer <Project, NoError>.buffer(1)
  let recommendations: SignalProducer<[Project], NoError>
  let saveAlert: Signal<(), NoError>
  let videoURL: SignalProducer<NSURL, NoError>
  let (openPlaylistsExplorer, openPlaylistsExplorerObserver) = Signal<Playlist, NoError>.pipe()
  let (videoTimelineProgress, videoTimelineProgressObserver) = Signal<CGFloat, NoError>.pipe()
  let (interfaceImportance, interfaceImportanceObserver) = Signal<Bool, NoError>.pipe()
  let (videoIsPlaying, videoIsPlayingObserver) = Signal<Bool, NoError>.pipe()
  var outputs: ProjectViewModelOutputs { return self }

  // MARK: Errors
  let savingRequiresLogin: Signal<(), NoError>
  var errors: ProjectViewModelErrors { return self }

  init(project initialProject: Project, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let currentUser = env.currentUser

    let (saveSignal, saveObserver) = Signal<(), NoError>.pipe()
    self.saveObserver = saveObserver

    let (saveAlertSignal, saveAlertObserver) = Signal<(), NoError>.pipe()
    self.saveAlert = saveAlertSignal

    let (savingRequiresLoginSignal, savingRequiresLoginObserver) = Signal<(), NoError>.pipe()
    savingRequiresLogin = savingRequiresLoginSignal

    apiService.fetchProject(initialProject).demoteErrors()
      .beginsWith(value: initialProject)
      .startWithNext(projectObserver.sendNext)

    videoURL = project
      .flatMap { $0.video?.high }
      .flatMap { NSURL(string: $0) }
      .skipRepeats(==)

    let loggedInUserOnSave = currentUser.producer.takeWhen(saveSignal)
      .filter(isNotNil)

    let loggedOutUserOnSave = currentUser.producer.takeWhen(saveSignal)
      .filter(isNil)
    loggedOutUserOnSave.ignoreValues().start(savingRequiresLoginObserver)

    let toggledStar = project.takeWhen(loggedInUserOnSave)
      .flatMap { p in apiService.toggleStar(p).demoteErrors() }

    toggledStar.start(projectObserver)

    toggledStar
      .filter { p in !p.endsIn48Hours }
      .filter { p in p.isStarred ?? false }
      .ignoreValues()
      .start(saveAlertObserver)

    self.recommendations = apiService.fetchProjects(DiscoveryParams(similarTo: initialProject))
          .demoteErrors()

    self.morePlaylistsClickSignal
      .map { Playlist.Featured }
      .observe(self.openPlaylistsExplorerObserver)

    self.scrollData
      .map(ProjectViewModel.ratioFromOffset)
      .observe(self.videoTimelineProgressObserver)

    self.isActive.observe(self.interfaceImportanceObserver)

    Signal.merge([
        self.isActive,
        self.remoteInteractionSignal.mapConst(true)
      ])
      .observe(self.interfaceImportanceObserver)

    self.interfaceImportance
      .filter { $0 }
      .debounce(4.0, onScheduler: QueueScheduler.mainQueueScheduler)
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
