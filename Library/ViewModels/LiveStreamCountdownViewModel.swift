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
  func closeButtonTapped()
  func configureWith(project: Project, liveStream: Project.LiveStream)
  func retrievedLiveStreamEvent(event: LiveStreamEvent)
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  var categoryId: Signal<Int, NoError> { get }
  var daysString: Signal<String, NoError> { get }
  var dismiss: Signal<(), NoError> { get }
  var hoursString: Signal<String, NoError> { get }
  var minutesString: Signal<String, NoError> { get }
  var projectImageUrl: Signal<URL, NoError> { get }
  var pushLiveStreamViewController: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }
  var secondsString: Signal<String, NoError> { get }
  var upcomingIntroText: Signal<String, NoError> { get }
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

    let countdownEnded = dateComponents
      .filter { $0.day <= 0 && $0.hour <= 0 && $0.minute <= 0 && $0.second < 0 }

    self.projectImageUrl = project
      .map { URL(string: $0.photo.full) }
      .skipNil()

    self.categoryId = project.map { $0.category.rootId }.skipNil()
    self.dismiss = self.closeButtonTappedProperty.signal
    self.viewControllerTitle = viewDidLoadProperty.signal.mapConst(
      Strings.Live_stream_countdown()
    )

    self.pushLiveStreamViewController = Signal.combineLatest(
      configData.map(flipProjectLiveStreamToLive),
      self.liveStreamEventProperty.signal.skipNil().map(flipLiveStreamEvenToLive)
      )
      .map(unpack)
      .takeWhen(countdownEnded)
      .take(first: 1)

    self.upcomingIntroText = project
      .map { Strings.Upcoming_with_creator_name(creator_name: $0.creator.name) }
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let configData = MutableProperty<(Project, Project.LiveStream)?>(nil)
  public func configureWith(project: Project, liveStream: Project.LiveStream) {
    self.configData.value = (project, liveStream)
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
  public let daysString: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let hoursString: Signal<String, NoError>
  public let minutesString: Signal<String, NoError>
  public let projectImageUrl: Signal<URL, NoError>
  public let pushLiveStreamViewController: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError>
  public let secondsString: Signal<String, NoError>
  public let upcomingIntroText: Signal<String, NoError>
  public let viewControllerTitle: Signal<String, NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}

private func flipProjectLiveStreamToLive(project: Project, currentLiveStream: Project.LiveStream) ->
  (Project, Project.LiveStream) {
  let liveStreams = project.liveStreams.map { liveStream in
    liveStream
      |> Project.LiveStream.lens.isLiveNow .~ (liveStream.id == currentLiveStream.id)
  }

  let flippedCurrentLiveStream = currentLiveStream |> Project.LiveStream.lens.isLiveNow .~ true

  return (project |> Project.lens.liveStreams .~ liveStreams, flippedCurrentLiveStream)
}

private func flipLiveStreamEvenToLive(event: LiveStreamEvent) -> LiveStreamEvent {
  return event |> LiveStreamEvent.lens.stream.liveNow .~ true
}
