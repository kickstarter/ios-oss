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

  /// Called when a live stream api error occurred.
  func liveStreamApiErrorOccurred(error: LiveApiError)

  /// Called when the LiveStreamViewController's state changed
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)

  /// Call when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamContainerViewModelOutputs {
  /// Emits whether the share bar button item should be added
  var addShareBarButtonItem: Signal<Bool, NoError> { get }

  /// Emits when the LiveStreamViewController should be configured
  var configureLiveStreamViewController: Signal<(Project, LiveStreamEvent), NoError> { get }

  /// Emits when the LiveStreamContainerPageViewController should be configured
  var configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError> { get }

  /// Emits when the nav bar title view should be configured.
  var configureNavBarTitleView: Signal<LiveStreamEvent, NoError> { get }

  /// Emits when the view controller should dismiss
  var dismiss: Signal<(), NoError> { get }

  /// Emits when the loader activity indicator should animate
  var loaderActivityIndicatorAnimating: Signal<Bool, NoError> { get }

  /// Emits when the loader stack view should be hidden
  var loaderStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the loader's text
  var loaderText: Signal<String, NoError> { get }

  /// Emits when the nav bar title view should be hidden.
  var navBarTitleViewHidden: Signal<Bool, NoError> { get }

  /// Emits the project's image url
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits when an error occurred
  var showErrorAlert: Signal<String, NoError> { get }

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
      .switchMap { initialEvent -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in

        timer(interval: .seconds(5), on: AppEnvironment.current.scheduler)
          .prefix(value: Date())
          .flatMap { _ in
            AppEnvironment.current.liveStreamService
              .fetchEvent(
                eventId: initialEvent.id,
                uid: AppEnvironment.current.currentUser?.id,
                liveAuthToken: AppEnvironment.current.currentUser?.liveAuthToken
              )
              .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
              .materialize()
          }
          .filter { event in
            if initialEvent.liveNow && event.error == nil {
              return event.value?.liveNow == .some(true)
            }

            return true
          }
          .take(first: 1)
    }

    let project = configData.map { project, _, _, _ in project }
    let refTag = configData.map { _, _, refTag, _ in refTag }
    let presentedFromProject = configData.map { _, _, _, presentedFromProject in presentedFromProject }

    self.configureLiveStreamViewController = Signal.combineLatest(project, updatedEventFetch.values())

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
      liveStreamControllerStateError,
      self.liveStreamApiErrorOccurredProperty.signal
        .skipNil()
        .map { $0.description }
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

    self.configureNavBarTitleView = updatedEventFetch.values()
    self.navBarTitleViewHidden = Signal.merge(
      initialEvent.mapConst(true),
      updatedEventFetch.values().mapConst(false)
    )

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

    self.addShareBarButtonItem = updatedEventFetch.values()
      .map { $0.liveNow }
      .map(negate)
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

  private let liveStreamApiErrorOccurredProperty = MutableProperty<LiveApiError?>(nil)
  public func liveStreamApiErrorOccurred(error: LiveApiError) {
    self.liveStreamApiErrorOccurredProperty.value = error
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

  // Required to limit the lifetime of the minutes watched tracking timer
  private let token = Lifetime.Token()

  public let addShareBarButtonItem: Signal<Bool, NoError>
  public let configureLiveStreamViewController: Signal<(Project, LiveStreamEvent), NoError>
  public let configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError>
  public let configureNavBarTitleView: Signal<LiveStreamEvent, NoError>
  public let dismiss: Signal<(), NoError>
  public let loaderActivityIndicatorAnimating: Signal<Bool, NoError>
  public let loaderStackViewHidden: Signal<Bool, NoError>
  public let loaderText: Signal<String, NoError>
  public let navBarTitleViewHidden: Signal<Bool, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let titleViewText: Signal<String, NoError>
  public let videoViewControllerHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}
