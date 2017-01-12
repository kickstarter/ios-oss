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
  var daysString: Signal<NSAttributedString, NoError> { get }
  var dismiss: Signal<(), NoError> { get }
  var hoursString: Signal<NSAttributedString, NoError> { get }
  var minutesString: Signal<NSAttributedString, NoError> { get }
  var projectImageUrl: Signal<URL, NoError> { get }
  var pushLiveStreamViewController: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }
  var secondsString: Signal<NSAttributedString, NoError> { get }
  var upcomingIntroText: Signal<NSAttributedString, NoError> { get }
  var viewControllerTitle: Signal<String, NoError> { get }
}

public final class LiveStreamCountdownViewModel: LiveStreamCountdownViewModelType,
LiveStreamCountdownViewModelInputs, LiveStreamCountdownViewModelOutputs {

  //swiftlint:disable function_body_length
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    let project = configData.map(first)
    let liveStream = configData.map(second)

    let everySecondTimer = self.viewDidLoadProperty.signal.flatMap {
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

    let days = dateComponents
      .map { max(0, $0.day ?? 0) }
      .skipRepeats()

    let hours = dateComponents
      .map { max(0, $0.hour ?? 0) }
      .skipRepeats()

    let minutes = dateComponents
      .map { max(0, $0.minute ?? 0) }
      .skipRepeats()

    let seconds = dateComponents
      .map { max(0, $0.second ?? 0) }
      .skipRepeats()

    //FIXME: Update below after make strings

    self.daysString = days
      .map { (String(format: "%02d", $0), localizedString(
        key: "days", defaultValue: "days")) }
      .map(attributedCountdownString(prefix:suffix:))

    self.hoursString = hours
      .map { (String(format: "%02d", $0), localizedString(
        key: "hours", defaultValue: "hours")) }
      .map(attributedCountdownString(prefix:suffix:))

    self.minutesString = minutes
      .map { (String(format: "%02d", $0), localizedString(
        key: "minutes", defaultValue: "minutes")) }
      .map(attributedCountdownString(prefix:suffix:))

    self.secondsString = seconds
      .map { (String(format: "%02d", $0), localizedString(
        key: "seconds", defaultValue: "seconds")) }
      .map(attributedCountdownString(prefix:suffix:))

    let countdownEnded = Signal.combineLatest(
      liveStream
        .map { AppEnvironment.current.dateType.init(timeIntervalSince1970: $0.startDate).date },
      everySecondTimer
      )
      .filter { startDate, now in startDate < now }

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
      .map { project -> NSAttributedString? in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let baseAttributes = [
          NSFontAttributeName: UIFont.ksr_subhead(size: 14),
          NSForegroundColorAttributeName: UIColor.ksr_navy_600,
          NSParagraphStyleAttributeName: paragraphStyle
        ]

        let boldAttributes = [
          NSFontAttributeName: UIFont.ksr_headline(size: 14),
          NSForegroundColorAttributeName: UIColor.ksr_navy_700,
          NSParagraphStyleAttributeName: paragraphStyle
        ]

        let text = Strings.Upcoming_with_creator_name(creator_name: project.creator.name)

        return text.simpleHtmlAttributedString(
          base: baseAttributes,
          bold: boldAttributes
        )
      }.skipNil()
  }
  //swiftlint:enable function_body_length

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
  public let daysString: Signal<NSAttributedString, NoError>
  public let dismiss: Signal<(), NoError>
  public let hoursString: Signal<NSAttributedString, NoError>
  public let minutesString: Signal<NSAttributedString, NoError>
  public let projectImageUrl: Signal<URL, NoError>
  public let pushLiveStreamViewController: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError>
  public let secondsString: Signal<NSAttributedString, NoError>
  public let upcomingIntroText: Signal<NSAttributedString, NoError>
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

private func attributedCountdownString(prefix: String, suffix: String) -> NSAttributedString {
  let fontDescriptorAttributes = [
    UIFontDescriptorFeatureSettingsAttribute: [
      [
        UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
        UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
      ]
    ]
  ]

  let fontDescriptor = UIFont.ksr_title1(size: 24)
    .fontDescriptor
    .addingAttributes(fontDescriptorAttributes)

  let prefixAttributes = [NSFontAttributeName: UIFont(descriptor: fontDescriptor, size: 24)]
  let suffixAttributes = [NSFontAttributeName: UIFont.ksr_headline(size: 14)]

  let prefix = NSMutableAttributedString(string: prefix, attributes: prefixAttributes)
  let suffix = NSAttributedString(string: "\n\(suffix)", attributes: suffixAttributes)
  prefix.append(suffix)

  return prefix
}
