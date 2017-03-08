// swiftlint:disable file_length
import KsApi
import LiveStream
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamContainerViewModelType {
  var inputs: LiveStreamContainerViewModelInputs { get }
  var outputs: LiveStreamContainerViewModelOutputs { get }
}

public protocol LiveStreamContainerViewModelInputs {
  /// Call with the Project, Project.LiveStream and LiveStreamEvent
  func configureWith(project: Project,
                     liveStreamEvent: LiveStreamEvent,
                     refTag: RefTag,
                     presentedFromProject: Bool)

  /// Call when the close button is tapped
  func closeButtonTapped()

  /// Call when the device's orientation changed
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Called when the LiveStreamViewController's state changed
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)

  /// Call when the viewDidLoad
  func viewDidLoad()

  /// Call when the more menu view controller will be presented
  func willPresentMoreMenuViewController()

  /// Call when the more menu view controller will be dismissed
  func willDismissMoreMenuViewController()
}

public protocol LiveStreamContainerViewModelOutputs {
  /// Emits when the LiveStreamViewController should be configured
  var configureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError> { get }

  /// Emits when the LiveStreamContainerPageViewController should be configured
  var configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError> { get }

  /// Emits when the live dot image above the creator avatar should be hidden
  var creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError> { get }

  /// Emits the intro text for the creator
  var creatorIntroText: Signal<String, NoError> { get }

  /// Emits when the view controller should dismiss
  var dismiss: Signal<(), NoError> { get }

  /// Emits when the modal overlay view should be displayed
  var displayModalOverlayView: Signal<(), NoError> { get }

  /// Emits when the loader activity indicator should animate
  var loaderActivityIndicatorAnimating: Signal<Bool, NoError> { get }

  /// Emits when the loader stack view should be hidden
  var loaderStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the loader's text
  var loaderText: Signal<String, NoError> { get }

  /// Emits when the nav bar's title view should be hidden
  var navBarTitleViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the live dot image in the nav bar title view should be hidden (e.g. in replay)
  var navBarLiveDotImageViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the number of people watching badge view should be hidden
  var numberWatchingBadgeViewHidden: Signal<Bool, NoError> { get }

  /// Emits the project's image url
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits when the modal overlay view should be removed
  var removeModalOverlayView: Signal<(), NoError> { get }

  /// Emits when an error occurred
  var showErrorAlert: Signal<String, NoError> { get }

  /// Emits the title view's text
  var titleViewText: Signal<String, NoError> { get }

  /// Emits when the video view controller should be hidden (when loading or green room is active)
  var videoViewControllerHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamContainerViewModel: LiveStreamContainerViewModelType,
LiveStreamContainerViewModelInputs, LiveStreamContainerViewModelOutputs {

  //swiftlint:disable function_body_length
  //swiftlint:disable cyclomatic_complexity
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let initialEvent = configData.map { _, event, _, _ in event }

    let updatedEventFetch = initialEvent
      .switchMap { event -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in

        timer(interval: .seconds(5), on: AppEnvironment.current.scheduler)
          .prefix(value: Date())
          .flatMap { _ in
            AppEnvironment.current.liveStreamService
              .fetchEvent(eventId: event.id, uid: AppEnvironment.current.currentUser?.id)
              .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
              .materialize()
          }
          .filter { event in
            event.value?.liveNow == .some(true) || event.value?.hasReplay == .some(true) || event.error != nil
          }
          .take(first: 1)
    }

    let project = configData.map { project, _, _, _ in project }
    let refTag = configData.map { _, _, refTag, _ in refTag }
    let presentedFromProject = configData.map { _, _, _, presentedFromProject in presentedFromProject }
    let event = Signal.merge(
      initialEvent,
      updatedEventFetch.values()
    )

    self.configureLiveStreamViewController = Signal.combineLatest(project, updatedEventFetch.values())
      .map { project, event in (project, AppEnvironment.current.currentUser?.id, event) }

    self.configurePageViewController = Signal.combineLatest(
      project, initialEvent, refTag, presentedFromProject
      )
      .map { project, event, refTag, presentedFromProject in (project, event, refTag, presentedFromProject) }

    let liveStreamControllerState = Signal.merge(
      Signal.combineLatest(
        self.liveStreamViewControllerStateChangedProperty.signal.skipNil(),
        self.viewDidLoadProperty.signal
      ).map(first),
      project.mapConst(.loading)
    )

    let eventFetchError = updatedEventFetch.errors().map { _ in
      return Strings.The_live_stream_failed_to_connect()
    }

    let liveStreamControllerStateError = liveStreamControllerState
      .map { state -> LiveVideoPlaybackError? in
        switch state {
        case .error(let error):                   return error
        case let .live(.error(videoError), _):    return videoError
        case let .replay(.error(videoError), _):  return videoError
        case .initializationFailed:               return .failedToConnect
        default:                                  return nil
        }
      }
      .skipNil()
      .map { error -> String in
        switch error {
        case .sessionInterrupted: return Strings.The_live_stream_was_interrupted()
        case .failedToConnect:    return Strings.The_live_stream_failed_to_connect()
        }
      }

    self.showErrorAlert = Signal.merge(
      eventFetchError,
      liveStreamControllerStateError
    )

    self.loaderText = Signal.merge(
      liveStreamControllerState.map {
        switch $0 {
        case .live(playbackState: .loading, _):   return Strings.The_live_stream_will_start_soon()
        case .greenRoom:                          return Strings.The_live_stream_will_start_soon()
        case .replay(playbackState: .loading, _): return Strings.The_replay_will_start_soon()
        case .nonStarter:                         return Strings.No_replay_is_available_for_this_live_stream()
        default:                                  return Strings.Loading()
        }
      },
      self.showErrorAlert
    )

    let nonStarter = liveStreamControllerState.map { state -> Bool in
      switch state {
      case .nonStarter: return true
      default:          return false
      }
    }

    self.loaderActivityIndicatorAnimating = Signal.merge(
      nonStarter.map(negate),
      self.showErrorAlert.mapConst(false)
    )

    self.loaderStackViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      liveStreamControllerState
        .map { state -> Bool in
          switch state {
          case .live(playbackState: .playing, _):
            return true
          case .replay(playbackState: .playing, _):
            return true
          default:
            return false
          }
        }
        .filter(isTrue)
        .take(first: 1)
    )

    self.projectImageUrl = project.flatMap { project in
      SignalProducer(value: URL(string: project.photo.full))
        .prefix(value: nil)
    }

    self.titleViewText = liveStreamControllerState.map {
      switch $0 {
      case .live(_, _):   return Strings.Live()
      case .greenRoom:    return Strings.Starting_soon()
      case .replay(_, _): return Strings.Recorded_Live()
      default:            return Strings.Loading()
      }
    }

    self.videoViewControllerHidden = Signal.combineLatest(
      liveStreamControllerState.map { state -> Bool in
        switch state {
        case .live(playbackState: .playing, _):   return false
        case .replay(playbackState: .playing, _): return false
        default:                                  return true
        }
      },
      self.configureLiveStreamViewController
      )
      .map(first)

    self.dismiss = self.closeButtonTappedProperty.signal

    self.creatorIntroText = event
      .observeForUI()
      .map { event in
        event.liveNow
          ? Strings.Live_with_creator_name(creator_name: event.creator.name)
          : Strings.Creator_name_was_live_time_ago(
            creator_name: event.creator.name,
            time_ago: Format.relative(secondsInUTC: event.startDate.timeIntervalSince1970,
                                      abbreviate: true)
        )
    }

    let hideWhenReplay = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      event.map { !$0.liveNow }
    ).skipRepeats()

    self.navBarTitleViewHidden = Signal.merge(
      project.mapConst(true),
      liveStreamControllerState.map { state in
        switch state {
        case .live(playbackState: .playing, _):   return false
        case .replay(playbackState: .playing, _): return false
        default:                                  return true
        }
      }
    ).skipRepeats()

    self.navBarLiveDotImageViewHidden = hideWhenReplay
    self.creatorAvatarLiveDotImageViewHidden = hideWhenReplay
    self.numberWatchingBadgeViewHidden = hideWhenReplay

    let numberOfMinutesWatched = liveStreamControllerState
      .filter { state in
        switch state {
        case .live(playbackState: .playing, _):   return true
        case .replay(playbackState: .playing, _): return true
        default:                                  return false
        }
      }
      .flatMap { _ in timer(interval: .seconds(60), on: AppEnvironment.current.scheduler) }
      .mapConst(1)

    self.displayModalOverlayView = self.willPresentMoreMenuViewControllerProperty.signal
    self.removeModalOverlayView = Signal.zip(
      self.displayModalOverlayView,
      self.willDismissMoreMenuViewControllerProperty.signal
    ).ignoreValues()

    configData
      .takePairWhen(self.deviceOrientationDidChangeProperty.signal.skipNil())
      .observeValues { data, orientation in
        let (project, liveStream, _, _) = data
        AppEnvironment.current.koala.trackChangedLiveStreamOrientation(project: project,
                                                                       liveStreamEvent: liveStream,
                                                                       toOrientation: orientation)
    }

    let startEndTimes = Signal.zip(
      configData.map { _ in AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970 },
      self.closeButtonTappedProperty.signal
        .map { _ in AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970 }
    )

    Signal.combineLatest(configData, startEndTimes)
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { (configData, startEndTimes) in
        let (project, liveStreamEvent, refTag, _) = configData
        let (startTime, endTime) = startEndTimes

        AppEnvironment.current.koala.trackClosedLiveStream(project: project,
                                                           liveStreamEvent: liveStreamEvent,
                                                           startTime: startTime,
                                                           endTime: endTime,
                                                           refTag: refTag)
    }

    configData
      .takePairWhen(numberOfMinutesWatched)
      .map { tuple, minute in (tuple.0, tuple.1, tuple.2, minute) }
      .take(during: Lifetime(self.token))
      .observeValues { project, liveStreamEvent, refTag, minute in
        AppEnvironment.current.koala.trackWatchedLiveStream(project: project,
                                                            liveStreamEvent: liveStreamEvent,
                                                            refTag: refTag,
                                                            duration: minute)
    }

    configData
      .observeValues { project, liveStreamEvent, refTag, _ in
        AppEnvironment.current.koala.trackViewedLiveStream(project: project,
                                                           liveStreamEvent: liveStreamEvent,
                                                           refTag: refTag)
    }
  }
  //swiftlint:enable function_body_length
  //swiftlint:enable cyclomatic_complexity

  private typealias ConfigData = (Project, LiveStreamEvent, RefTag, Bool)
  private let configData = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project,
                            liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configData.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let deviceOrientationDidChangeProperty = MutableProperty<UIInterfaceOrientation?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation) {
    self.deviceOrientationDidChangeProperty.value = orientation
  }

  private let liveStreamViewControllerStateChangedProperty =
    MutableProperty<LiveStreamViewControllerState?>(nil)
  public func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState) {
    self.liveStreamViewControllerStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willDismissMoreMenuViewControllerProperty = MutableProperty()
  public func willDismissMoreMenuViewController() {
    self.willDismissMoreMenuViewControllerProperty.value = ()
  }

  private let willPresentMoreMenuViewControllerProperty = MutableProperty()
  public func willPresentMoreMenuViewController() {
    self.willPresentMoreMenuViewControllerProperty.value = ()
  }

  // Required to limit the lifetime of the minutes watched tracking timer
  private let token = Lifetime.Token()

  public let configureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError>
  public let configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError>
  public let creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let creatorIntroText: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let displayModalOverlayView: Signal<(), NoError>
  public let loaderActivityIndicatorAnimating: Signal<Bool, NoError>
  public let loaderStackViewHidden: Signal<Bool, NoError>
  public let loaderText: Signal<String, NoError>
  public let navBarTitleViewHidden: Signal<Bool, NoError>
  public let navBarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let numberWatchingBadgeViewHidden: Signal<Bool, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let removeModalOverlayView: Signal<(), NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let titleViewText: Signal<String, NoError>
  public let videoViewControllerHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}
