import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude
import LiveStream

public protocol LiveStreamCountdownViewModelType {
  var inputs: LiveStreamCountdownViewModelInputs { get }
  var outputs: LiveStreamCountdownViewModelOutputs { get }
}

public protocol LiveStreamCountdownViewModelInputs {
  /// Called when the close button is tapped
  func closeButtonTapped()

  /// Call with the Project and the specific LiveStream that is being viewed
  func configureWith(project: Project, liveStream: Project.LiveStream, context: Koala.LiveStreamContext)

  /// Called when the LiveStreamEvent has been retrieved
  func retrievedLiveStreamEvent(event: LiveStreamEvent)

  /// Called when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  /// Emits the project's root category ID
  var categoryId: Signal<Int, NoError> { get }

  /// Emits the accessibility label string for the live stream countdown
  var countdownAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the countdown date label text
  var countdownDateLabelText: Signal<String, NoError> { get }

  /// Emits the number of days string for the countdown
  var daysString: Signal<String, NoError> { get }

  /// Emits when the view controller should be dismissed
  var dismiss: Signal<(), NoError> { get }

  /// Emits the number of hours string for the countdown
  var hoursString: Signal<String, NoError> { get }

  /// Emits the number of minutes string for the countdown
  var minutesString: Signal<String, NoError> { get }

  /// Emits the project image url
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits when the countdown ends and the LiveStreamViewController should be pushed on to the stack
  var pushLiveStreamViewController:
    Signal<(Project, Project.LiveStream, LiveStreamEvent, Koala.LiveStreamContext), NoError> { get }

  /// Emits the number of seconds string for the countdown
  var secondsString: Signal<String, NoError> { get }

  /// Emits the upcoming intro text
  var upcomingIntroText: Signal<String, NoError> { get }

  /// Emits the view controller's title text
  var viewControllerTitle: Signal<String, NoError> { get }
}

public final class LiveStreamCountdownViewModel: LiveStreamCountdownViewModelType,
LiveStreamCountdownViewModelInputs, LiveStreamCountdownViewModelOutputs {

  //swiftlint:disable:next function_body_length
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    let project = configData.map(first)
    let liveStream = configData.map(second)

    let everySecondTimer = self.viewDidLoadProperty.signal
      .flatMap {
        timer(interval: .seconds(1), on: AppEnvironment.current.scheduler)
          .prefix(value: AppEnvironment.current.scheduler.currentDate)
    }

    let dateComponents = liveStream
      .map { AppEnvironment.current.dateType.init(timeIntervalSince1970: $0.startDate).date }
      .takePairWhen(everySecondTimer)
      .map { startDate, currentDate in
        AppEnvironment.current.calendar.dateComponents([.day, .hour, .minute, .second],
                                                       from: currentDate,
                                                       to: startDate)
      }
      .map { (day: $0.day ?? 0, hour: $0.hour ?? 0, minute: $0.minute ?? 0, second: $0.second ?? 0) }

    self.countdownDateLabelText = liveStream
      .map { Date(timeIntervalSince1970: $0.startDate) }.map(formattedDateString)

    self.daysString = dateComponents
      .map { max(0, $0.day) }
      .skipRepeats()
      .map { String(format: "%02d", $0) }

    self.hoursString = dateComponents
      .map { max(0, $0.hour) }
      .skipRepeats()
      .map { String(format: "%02d", $0) }

    self.minutesString = dateComponents
      .map { max(0, $0.minute) }
      .skipRepeats()
      .map { String(format: "%02d", $0) }

    self.secondsString = dateComponents
      .map { max(0, $0.second) }
      .skipRepeats()
      .map { String(format: "%02d", $0) }

    self.countdownAccessibilityLabel = liveStream.map { liveStream in
      localizedString(
        key: "The_live_stream_will_start_time",
        defaultValue: "The live stream will start %{time}.",
        substitutions: ["time": Format.relative(secondsInUTC: liveStream.startDate)])
    }

    let countdownEnded = dateComponents
      .filter { $0.day <= 0 && $0.hour <= 0 && $0.minute <= 0 && $0.second < 0 }

    self.projectImageUrl = project
      .map { URL(string: $0.photo.full) }

    self.categoryId = project.map { $0.category.rootId }.skipNil()
    self.dismiss = self.closeButtonTappedProperty.signal
    self.viewControllerTitle = viewDidLoadProperty.signal.mapConst(
      Strings.Live_stream_countdown()
    )

    self.pushLiveStreamViewController = Signal.combineLatest(
      configData.map { project, liveStream, _ in (project, liveStream) }.map(flipProjectLiveStreamToLive),
      self.liveStreamEventProperty.signal.skipNil().map(flipLiveStreamEventToLive)
      )
      .map(unpack)
      .map { project, liveStream, event in (project, liveStream, event, .countdown) }
      .takeWhen(countdownEnded)
      .take(first: 1)

    self.upcomingIntroText = project
      .map { Strings.Upcoming_with_creator_name(creator_name: $0.creator.name) }

    configData
      .observeValues { project, liveStream, context in
        AppEnvironment.current.koala.trackViewedLiveStreamCountdown(project: project,
                                                                    liveStream: liveStream,
                                                                    context: context)
    }
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let configData = MutableProperty<(Project, Project.LiveStream, Koala.LiveStreamContext)?>(nil)
  public func configureWith(project: Project,
                            liveStream: Project.LiveStream,
                            context: Koala.LiveStreamContext) {
    self.configData.value = (project, liveStream, context)
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func retrievedLiveStreamEvent(event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let categoryId: Signal<Int, NoError>
  public let countdownAccessibilityLabel: Signal<String, NoError>
  public let countdownDateLabelText: Signal<String, NoError>
  public let daysString: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let hoursString: Signal<String, NoError>
  public let minutesString: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let pushLiveStreamViewController:
    Signal<(Project, Project.LiveStream, LiveStreamEvent, Koala.LiveStreamContext), NoError>
  public let secondsString: Signal<String, NoError>
  public let upcomingIntroText: Signal<String, NoError>
  public let viewControllerTitle: Signal<String, NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}

private func flipProjectLiveStreamToLive(project: Project, currentLiveStream: Project.LiveStream) ->
  (Project, Project.LiveStream) {
  let liveStreams = (project.liveStreams ?? [])
    .map { liveStream in
      liveStream
        |> Project.LiveStream.lens.isLiveNow .~ (liveStream.id == currentLiveStream.id)
  }

  let flippedCurrentLiveStream = currentLiveStream
    |> Project.LiveStream.lens.isLiveNow .~ true

  return (project |> Project.lens.liveStreams .~ liveStreams, flippedCurrentLiveStream)
}

private func flipLiveStreamEventToLive(event: LiveStreamEvent) -> LiveStreamEvent {
  return event |> LiveStreamEvent.lens.stream.liveNow .~ true
}

private func formattedDateString(date: Date) -> String {

  let format = DateFormatter.dateFormat(fromTemplate: "dMMMhmzzz",
                                        options: 0,
                                        locale: AppEnvironment.current.locale) ?? "MMM d, h:mm a zzz"

  return Format.date(secondsInUTC: date.timeIntervalSince1970, dateFormat: format)
}
