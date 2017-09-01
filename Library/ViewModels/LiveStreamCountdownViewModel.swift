import LiveStream
import Prelude
import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamCountdownViewModelType {
  var inputs: LiveStreamCountdownViewModelInputs { get }
  var outputs: LiveStreamCountdownViewModelOutputs { get }
}

public protocol LiveStreamCountdownViewModelInputs {
  /// Called when the close button is tapped
  func closeButtonTapped()

  /// Call with the data that is given to the view.
  func configureWith(project: Project,
                     liveStreamEvent: LiveStreamEvent,
                     refTag: RefTag,
                     presentedFromProject: Bool)

  /// Call when the project page button is pressed.
  func goToProjectButtonTapped()

  /// Called when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  /// Emits the accessibility label string for the live stream countdown
  var countdownAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the countdown date label text
  var countdownDateLabelText: Signal<String, NoError> { get }

  /// Emits the number of days string for the countdown
  var daysString: Signal<String, NoError> { get }

  /// Emits when the view controller should be dismissed
  var dismiss: Signal<(), NoError> { get }

  /// Emits a project and ref tag when we should navigate to the project page.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a boolean that determines if the project button container is hidden.
  var goToProjectButtonContainerHidden: Signal<Bool, NoError> { get }

  /// Emits the number of hours string for the countdown
  var hoursString: Signal<String, NoError> { get }

  /// Emits the number of minutes string for the countdown
  var minutesString: Signal<String, NoError> { get }

  /// Emits the project image url
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits when the countdown ends and the LiveStreamViewController should be pushed on to the stack
  var pushLiveStreamViewController: Signal<(Project, LiveStreamEvent, RefTag), NoError> { get }

  /// Emits the number of seconds string for the countdown
  var secondsString: Signal<String, NoError> { get }

  /// Emits the upcoming intro text
  var upcomingIntroText: Signal<String, NoError> { get }

  /// Emits the view controller's title text
  var viewControllerTitle: Signal<String, NoError> { get }
}

public final class LiveStreamCountdownViewModel: LiveStreamCountdownViewModelType,
LiveStreamCountdownViewModelInputs, LiveStreamCountdownViewModelOutputs {

  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    let project = configData.map { project, _, _, _ in project }
    let liveStream = configData.map { _, liveStream, _, _ in liveStream }

    let dateComponents = liveStream
      .take(first: 1)
      .switchMap { countdownProducer(to: $0.startDate) }

    self.countdownDateLabelText = liveStream
      .map { $0.startDate }.map(formattedDateString)

    self.daysString = dateComponents
      .map { $0.day }
      .skipRepeats()

    self.hoursString = dateComponents
      .map { $0.hour }
      .skipRepeats()

    self.minutesString = dateComponents
      .map { $0.minute }
      .skipRepeats()

    self.secondsString = dateComponents
      .map { $0.second }
      .skipRepeats()

    self.countdownAccessibilityLabel = liveStream.map { liveStream in
      Strings.The_live_stream_will_start_time(
        time: Format.relative(secondsInUTC: liveStream.startDate.timeIntervalSince1970)
      )
    }

    let countdownEnded = dateComponents
      .materialize()
      .filter { $0.isTerminating }

    self.projectImageUrl = project.flatMap { project in
      SignalProducer(value: URL(string: project.photo.full))
        .prefix(value: nil)
    }

    self.dismiss = self.closeButtonTappedProperty.signal
    self.viewControllerTitle = viewDidLoadProperty.signal.mapConst(
      Strings.Live_stream_countdown()
    )

    self.pushLiveStreamViewController = configData
      .takeWhen(countdownEnded)
      .map { project, liveStream, _, _ in
        (project, flipLiveStreamEventToLive(liveStreamEvent: liveStream))
      }
      .map { project, liveStream in (project, liveStream, .liveStreamCountdown) }
      .take(first: 1)

    self.upcomingIntroText = project
      .map { Strings.Upcoming_with_creator_name(creator_name: $0.creator.name) }

    self.goToProject = configData
      .takeWhen(self.goToProjectButtonTappedProperty.signal)
      .map { project, _, _, _ in (project, RefTag.liveStreamCountdown) }

    self.goToProjectButtonContainerHidden = configData
      .map { _, _, _, presentedFromProject in presentedFromProject }

    configData
      .observeValues { project, liveStreamEvent, refTag, _ in
        AppEnvironment.current.koala.trackViewedLiveStreamCountdown(project: project,
                                                                    liveStreamEvent: liveStreamEvent,
                                                                    refTag: refTag)
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
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent, RefTag, Bool)?>(nil)
  public func configureWith(project: Project,
                            liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configData.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let goToProjectButtonTappedProperty = MutableProperty()
  public func goToProjectButtonTapped() {
    self.goToProjectButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let countdownAccessibilityLabel: Signal<String, NoError>
  public let countdownDateLabelText: Signal<String, NoError>
  public let daysString: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let goToProjectButtonContainerHidden: Signal<Bool, NoError>
  public let hoursString: Signal<String, NoError>
  public let minutesString: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let pushLiveStreamViewController: Signal<(Project, LiveStreamEvent, RefTag), NoError>
  public let secondsString: Signal<String, NoError>
  public let upcomingIntroText: Signal<String, NoError>
  public let viewControllerTitle: Signal<String, NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}

private func flipLiveStreamEventToLive(liveStreamEvent: LiveStreamEvent) -> LiveStreamEvent {
  return liveStreamEvent |> LiveStreamEvent.lens.liveNow .~ true
}

private func formattedDateString(date: Date) -> String {

  let format = DateFormatter.dateFormat(fromTemplate: "dMMMhmzzz",
                                        options: 0,
                                        locale: AppEnvironment.current.locale) ?? "MMM d, h:mm a zzz"

  return Format.date(secondsInUTC: date.timeIntervalSince1970, template: format)
}
