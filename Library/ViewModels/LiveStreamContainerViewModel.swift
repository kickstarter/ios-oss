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
  func configureWith(project: Project, event: LiveStreamEvent?)
  func closeButtonTapped()
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)
  func retrievedLiveStreamEvent(event: LiveStreamEvent)
  func viewDidLoad()
}

public protocol LiveStreamContainerViewModelOutputs {
  var availableForLabelHidden: Signal<Bool, NoError> { get }
  var createAndConfigureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError> { get }
  var creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError> { get }
  var creatorIntroText: Signal<NSAttributedString, NoError> { get }
  var dismiss: Signal<(), NoError> { get }
  var liveStreamState: Signal<LiveStreamViewControllerState, NoError> { get }
  var loaderText: Signal<String, NoError> { get }
  var navBarLiveDotImageViewHidden: Signal<Bool, NoError> { get }
  var numberWatchingButtonHidden: Signal<Bool, NoError> { get }
  var projectImageUrl: Signal<URL, NoError> { get }
  var showErrorAlert: Signal<String, NoError> { get }
  var videoViewControllerHidden: Signal<Bool, NoError> { get }
  var titleViewText: Signal<String, NoError> { get }
}

public final class LiveStreamContainerViewModel: LiveStreamContainerViewModelType,
LiveStreamContainerViewModelInputs, LiveStreamContainerViewModelOutputs {

  //swiftlint:disable function_body_length
  //swiftlint:disable cyclomatic_complexity
  public init() {
    let project = Signal.combineLatest(
      self.projectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    self.createAndConfigureLiveStreamViewController = Signal.combineLatest(
      self.projectProperty.signal.skipNil(),
      self.liveStreamEventProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      ).map { project, event, _ in (project, AppEnvironment.current.currentUser?.id, event) }

    self.liveStreamState = Signal.combineLatest(
      Signal.merge(
        self.liveStreamViewControllerStateChangedProperty.signal.skipNil(),
        project.mapConst(.loading)
      ),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.showErrorAlert = self.liveStreamState.map { state -> LiveVideoPlaybackError? in
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

    self.loaderText = liveStreamState.map {
      if case .live(playbackState: .loading, _) = $0 { return Strings.The_live_stream_will_start_soon() }
      if case .greenRoom = $0 { return Strings.The_live_stream_will_start_soon() }
      if case .replay(playbackState: .loading, _) = $0 {
        return Strings.The_replay_will_start_soon()
      }

      return Strings.Loading()
    }

    self.projectImageUrl = project
      .map { URL(string: $0.photo.full) }
      .skipNil()

    self.titleViewText = liveStreamState.map {
      if case .live(_, _) = $0 { return Strings.Live() }
      if case .greenRoom = $0 { return Strings.Starting_soon() }
      if case .replay(_, _) = $0 { return Strings.Recorded_Live() }

      return Strings.Loading()
    }

    self.videoViewControllerHidden = Signal.combineLatest(
        self.liveStreamState.map {
          if case .live(playbackState: .playing, _) = $0 { return true }
          if case .replay(playbackState: .playing, _) = $0 { return true }

          return false
        },
        self.createAndConfigureLiveStreamViewController
      )
      .map(first)
      .map(negate)

    self.dismiss = self.closeButtonTappedProperty.signal

    self.creatorIntroText = Signal.combineLatest(
      Signal.merge(
        self.liveStreamViewControllerStateChangedProperty.signal.skipNil(),
        project.mapConst(.loading)
      ),
      liveStreamEventProperty.signal.skipNil()
      )
      .observeForUI()
      .map { (state, event) -> NSAttributedString? in

        let baseAttributes = [
          NSFontAttributeName: UIFont.ksr_body(size: 13),
          NSForegroundColorAttributeName: UIColor.white
        ]
        let boldAttributes = [
          NSFontAttributeName: UIFont.ksr_headline(size: 13),
          NSForegroundColorAttributeName: UIColor.white
        ]

        if case .live = state {
          let text = Strings.Creator_name_is_live_now(creator_name: event.creator.name)

          return text.simpleHtmlAttributedString(
            base: baseAttributes,
            bold: boldAttributes
          )
        }

        if case .replay = state {
          let text = Strings.Creator_name_was_live_time_ago(
            creator_name: event.creator.name,
            time_ago: (Format.relative(secondsInUTC: event.stream.startDate.timeIntervalSince1970,
              abbreviate: true)))

          return text.simpleHtmlAttributedString(
            base: baseAttributes,
            bold: boldAttributes
          )
        }

        return NSAttributedString(string: "")
      }.skipNil()

    let isLive: Signal<Bool, NoError> = self.liveStreamState
      .map {
        if case .live = $0 { return true }
        return false
    }

    let isReplay: Signal<Bool, NoError> = self.liveStreamState
      .observeForUI()
      .map {
        if case .replay = $0 { return true }
        return false
    }

    self.navBarLiveDotImageViewHidden = isLive.map(negate)
    self.creatorAvatarLiveDotImageViewHidden = isLive.map(negate)
    self.numberWatchingButtonHidden = isLive.map(negate)
    self.availableForLabelHidden = isReplay.map(negate)
  }
  //swiftlint:enable function_body_length
  //swiftlint:enable cyclomatic_complexity

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project, event: LiveStreamEvent?) {
    self.projectProperty.value = project
    self.liveStreamEventProperty.value = event
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
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
  public let createAndConfigureLiveStreamViewController: Signal<(Project, Int?, LiveStreamEvent), NoError>
  public let creatorAvatarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let creatorIntroText: Signal<NSAttributedString, NoError>
  public let dismiss: Signal<(), NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let liveStreamState: Signal<LiveStreamViewControllerState, NoError>
  public let loaderText: Signal<String, NoError>
  public let navBarLiveDotImageViewHidden: Signal<Bool, NoError>
  public let numberWatchingButtonHidden: Signal<Bool, NoError>
  public let projectImageUrl: Signal<URL, NoError>
  public let titleViewText: Signal<String, NoError>
  public let videoViewControllerHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}
