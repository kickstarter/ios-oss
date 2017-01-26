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
                     refTag: RefTag)

  /// Called when the close button is tapped
  func closeButtonTapped()

  /// Called when the device's orientation changed
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Called when the LiveStreamViewController's state changed
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)

  /// Called when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamContainerViewModelOutputs {
  /// Emits when the replay's available for text should be hidden
  var availableForLabelHidden: Signal<Bool, NoError> { get }

  /// Emits the text describing the replay's availability
  var availableForText: Signal<String, NoError> { get }

  /// Emits when the LiveStreamViewController should be created
  var createAndConfigureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError> { get }

  /// Emits when the live dot image above the creator avatar should be hidden
  var creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError> { get }

  /// Emits the intro text for the creator
  var creatorIntroText: Signal<String, NoError> { get }

  /// Emits when the view controller should dismiss
  var dismiss: Signal<(), NoError> { get }

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

    let project = configData.map(first)
    let event = configData.map(second)

    self.createAndConfigureLiveStreamViewController = Signal.combineLatest(project, event)
      .take(first: 1)
      .map { project, event in (project, AppEnvironment.current.currentUser?.id, event) }

    let liveStreamControllerState = Signal.merge(
      Signal.combineLatest(
        self.liveStreamViewControllerStateChangedProperty.signal.skipNil(),
        self.viewDidLoadProperty.signal
      ).map(first),
      project.mapConst(.loading)
    )

    self.showErrorAlert = liveStreamControllerState
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
      .map { error in
        switch error {
        case .sessionInterrupted: return Strings.The_live_stream_was_interrupted()
        case .failedToConnect:    return Strings.The_live_stream_failed_to_connect()
        }
      }

    self.availableForText = event
      .map { event -> String? in
        guard let availableDate = AppEnvironment.current.calendar
          .date(byAdding: .day, value: 2, to: event.startDate)?.timeIntervalSince1970
          else { return nil }

        let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

        return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
      }.skipNil()

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

    self.loaderActivityIndicatorAnimating = nonStarter.map(negate)

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

    self.projectImageUrl = project
      .map { URL(string: $0.photo.full) }

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
      self.createAndConfigureLiveStreamViewController
      )
      .map(first)

    self.dismiss = self.closeButtonTappedProperty.signal

    self.creatorIntroText = event
      .observeForUI()
      .map { event in
        event.liveNow
          ? Strings.Creator_name_is_live_now(creator_name: event.creator.name)
          : Strings.Creator_name_was_live_time_ago(
            creator_name: event.creator.name,
            time_ago: Format.relative(secondsInUTC: event.startDate.timeIntervalSince1970,
                                      abbreviate: true)
        )
    }

    let hideWhenReplay = Signal.merge(
      project.mapConst(true),
      event.map { !$0.liveNow },
      self.showErrorAlert.mapConst(true)
    ).skipRepeats()

    let hideWhenLive = Signal.merge(
      project.mapConst(true),
      event.map { $0.liveNow },
      self.showErrorAlert.mapConst(true)
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
    self.availableForLabelHidden = Signal.combineLatest(nonStarter, hideWhenLive).map { $0 || $1 }

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

    configData
      .takePairWhen(self.deviceOrientationDidChangeProperty.signal.skipNil())
      .observeValues { data, orientation in
        let (project, liveStream, _) = data
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
        let (project, liveStreamEvent, refTag) = configData
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
      .observeValues { project, liveStreamEvent, refTag in
        AppEnvironment.current.koala.trackViewedLiveStream(project: project,
                                                           liveStreamEvent: liveStreamEvent,
                                                           refTag: refTag)
    }
  }
  //swiftlint:enable function_body_length
  //swiftlint:enable cyclomatic_complexity

  private typealias ConfigData = (Project, LiveStreamEvent, RefTag)
  private let configData = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project,
                            liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag) {
    self.configData.value = (project, liveStreamEvent, refTag)
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

  // Required to limit the lifetime of the minutes watched tracking timer
  private let token = Lifetime.Token()

  public let availableForLabelHidden: Signal<Bool, NoError>
  public let availableForText: Signal<String, NoError>
  public let createAndConfigureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError>
  public let creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let creatorIntroText: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let loaderActivityIndicatorAnimating: Signal<Bool, NoError>
  public let loaderStackViewHidden: Signal<Bool, NoError>
  public let loaderText: Signal<String, NoError>
  public let navBarTitleViewHidden: Signal<Bool, NoError>
  public let navBarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let numberWatchingBadgeViewHidden: Signal<Bool, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let titleViewText: Signal<String, NoError>
  public let videoViewControllerHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}
