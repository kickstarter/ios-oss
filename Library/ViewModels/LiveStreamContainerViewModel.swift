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
  /// Call with the Project, Project.LiveStream and optional LiveStreamEvent
  func configureWith(project: Project, liveStream: Project.LiveStream, event: LiveStreamEvent?,
                     context: Koala.LiveStreamContext)

  /// Called when the close button is tapped
  func closeButtonTapped()

  /// Called when the device's orientation changed
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Called when the LiveStreamViewController's state changed
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)

  /// Called when the LiveStreamEvent was retrieved
  func retrievedLiveStreamEvent(event: LiveStreamEvent)

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

  /// Emits the current LiveStreamViewControllerState
  var liveStreamState: Signal<LiveStreamViewControllerState, NoError> { get }

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

    configData.observeValues { project, liveStream, _, context in
      AppEnvironment.current.koala.trackViewedLiveStream(project: project,
                                                         liveStream: liveStream,
                                                         context: context)
    }

    let project = configData.map { $0.0 }

    let liveStream = configData.map { $0.1 }

    let event = Signal.merge(
      configData.map { $0.2 }.skipNil(),
      self.liveStreamEventProperty.signal.skipNil()
    )

    self.createAndConfigureLiveStreamViewController = Signal.combineLatest(project, event)
      .take(first: 1)
      .map { project, event -> (Project, Int?, LiveStreamEvent) in
        (project, AppEnvironment.current.currentUser?.id, event)
    }

    self.liveStreamState = Signal.combineLatest(
      Signal.merge(
        self.liveStreamViewControllerStateChangedProperty.signal.skipNil(),
        project.mapConst(.loading)
      ),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.showErrorAlert = self.liveStreamState
      .map { state -> LiveVideoPlaybackError? in
        switch state {
        case .error(let error): return error
        case .live(let playbackState, _):
          if case let .error(videoError) = playbackState { return videoError }
        case .replay(let playbackState, _):
          if case let .error(videoError) = playbackState { return videoError }
        case .initializationFailed:
          return .failedToConnect
        default:
          return nil
        }
        return nil
      }
      .skipNil()
      .map {
        switch $0 {
        case .sessionInterrupted:
          return Strings.The_live_stream_was_interrupted()
        case .failedToConnect:
          return Strings.The_live_stream_failed_to_connect()
        }
      }

    self.availableForText = event
      .map { event -> String? in
        guard let availableDate = AppEnvironment.current.calendar
          .date(byAdding: .day, value: 2, to: event.stream.startDate)?.timeIntervalSince1970
          else { return nil }

        let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

        return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
      }.skipNil()

    self.loaderText = Signal.merge(
      self.liveStreamState.map {
        switch $0 {
        case .live(playbackState: .loading, _):   return Strings.The_live_stream_will_start_soon()
        case .greenRoom:                          return Strings.The_live_stream_will_start_soon()
        case .replay(playbackState: .loading, _): return Strings.The_replay_will_start_soon()
        default: return Strings.Loading()
        }
      },
      self.showErrorAlert
    )

    let everyMinuteTimer = self.viewDidLoadProperty.signal
      .flatMap {
        timer(interval: .seconds(60), on: AppEnvironment.current.scheduler)
    }

    let watchedAnotherMinute = Signal.combineLatest(
      everyMinuteTimer,
      self.liveStreamState.filter { state -> Bool in
        switch state {
        case .live(playbackState: .playing, _):   return true
        case .replay(playbackState: .playing, _): return true
        default: return false
        }
      }
      )
      .ignoreValues()
      .scan(0) { accum, _ in accum + 1 }

    Signal.combineLatest(
      configData.map { project, liveStream, _, context in (project, liveStream, context) },
      watchedAnotherMinute,
      liveStreamState
      )
      .map { tuple, minute, state in (tuple.0, tuple.1, tuple.2, minute, state) }
      .observeValues { project, liveStream, context, minute, state in
        switch state {
        case .live:
          AppEnvironment.current.koala
            .trackWatchedLiveStream(project: project,
                                    liveStream: liveStream,
                                    context: context,
                                    duration: minute)
        case .replay:
          AppEnvironment.current.koala
            .trackWatchedLiveStreamReplay(project: project,
                                          liveStream: liveStream,
                                          context: context,
                                          duration: minute)
        case .greenRoom, .error, .initializationFailed, .loading, .nonStarter:
          break
        }
    }

    self.loaderStackViewHidden = self.liveStreamState
      .map { state in
        switch state {
        case .live(playbackState: .playing, _):   return true
        case .replay(playbackState: .playing, _): return true
        default: return false
        }
      }
      .skipRepeats()

    self.projectImageUrl = project
      .map { URL(string: $0.photo.full) }

    self.titleViewText = liveStreamState.map {
      switch $0 {
      case .live(_, _):   return Strings.Live()
      case .greenRoom:    return Strings.Starting_soon()
      case .replay(_, _): return Strings.Recorded_Live()
      default: return Strings.Loading()
      }
    }

    self.videoViewControllerHidden = Signal.combineLatest(
      self.liveStreamState.map { state -> Bool in
        switch state {
        case .live(playbackState: .playing, _):   return false
        case .replay(playbackState: .playing, _): return false
        default: return true
        }
      },
      self.createAndConfigureLiveStreamViewController
      )
      .map(first)

    self.dismiss = self.closeButtonTappedProperty.signal

    self.creatorIntroText = event
      .observeForUI()
      .map { event in
        event.stream.liveNow
          ? Strings.Creator_name_is_live_now(creator_name: event.creator.name)
          : Strings.Creator_name_was_live_time_ago(
            creator_name: event.creator.name,
            time_ago: Format.relative(secondsInUTC: event.stream.startDate.timeIntervalSince1970,
                                      abbreviate: true)
        )
    }

    let hideWhenReplay = Signal.merge(
      project.mapConst(true),
      event.map { !$0.stream.liveNow },
      self.showErrorAlert.mapConst(true)
    ).skipRepeats()

    let hideWhenLive = Signal.merge(
      project.mapConst(true),
      event.map { $0.stream.liveNow },
      self.showErrorAlert.mapConst(true)
    ).skipRepeats()

    self.navBarTitleViewHidden = Signal.merge(
      project.mapConst(true),
      liveStreamState.map { state in
        switch state {
        case .live(playbackState: .playing, _):   return false
        case .replay(playbackState: .playing, _): return false
        default: return true
        }
      }
    ).skipRepeats()

    self.navBarLiveDotImageViewHidden = hideWhenReplay
    self.creatorAvatarLiveDotImageViewHidden = hideWhenReplay
    self.numberWatchingBadgeViewHidden = hideWhenReplay
    self.availableForLabelHidden = hideWhenLive

    Signal.combineLatest(
      project,
      liveStream,
      self.deviceOrientationDidChangeProperty.signal.skipNil()
    )
      .observeValues { project, liveStream, orientation in
        AppEnvironment.current.koala
          .trackChangedLiveStreamOrientation(project: project,
                                             liveStream: liveStream,
                                             context: liveStream.isLiveNow ? .live : .replay,
                                             toOrientation: orientation)
    }
  }
  //swiftlint:enable function_body_length
  //swiftlint:enable cyclomatic_complexity

  private let configData = MutableProperty<(Project, Project.LiveStream, LiveStreamEvent?,
    Koala.LiveStreamContext)?>(nil)
  public func configureWith(project: Project, liveStream: Project.LiveStream, event: LiveStreamEvent?,
                            context: Koala.LiveStreamContext) {
    self.configData.value = (project, liveStream, event, context: context)
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

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func retrievedLiveStreamEvent(event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let availableForLabelHidden: Signal<Bool, NoError>
  public let availableForText: Signal<String, NoError>
  public let createAndConfigureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError>
  public let creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let creatorIntroText: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let liveStreamState: Signal<LiveStreamViewControllerState, NoError>
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
