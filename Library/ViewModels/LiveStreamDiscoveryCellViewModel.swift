import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryCellViewModelInputs {
  func configureWith(liveStreamEvent: LiveStreamEvent)
}

public protocol LiveStreamDiscoveryCellViewModelOutputs {
  var backgroundImageUrl: Signal<URL?, NoError> { get }
  var countdownStackViewHidden: Signal<Bool, NoError> { get }
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var dateLabelText: Signal<String, NoError> { get }
  var dayCountLabelText: Signal<String, NoError> { get }
  var hourCountLabelText: Signal<String, NoError> { get }
  var minuteCountLabelText: Signal<String, NoError> { get }
  var nameLabelText: Signal<String, NoError> { get }
  var secondCountLabelText: Signal<String, NoError> { get }
  var watchButtonHidden: Signal<Bool, NoError> { get }
}

public protocol LiveStreamDiscoveryCellViewModelType {
  var inputs: LiveStreamDiscoveryCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryCellViewModelOutputs { get }
}

public final class LiveStreamDiscoveryCellViewModel: LiveStreamDiscoveryCellViewModelType,
LiveStreamDiscoveryCellViewModelInputs, LiveStreamDiscoveryCellViewModelOutputs {

  public init() {
    let liveStreamEvent = self.liveStreamEventProperty.signal.skipNil()

    self.backgroundImageUrl = liveStreamEvent
      .map { URL(string: $0.backgroundImageUrl) }

    self.countdownStackViewHidden = liveStreamEvent
      .map { $0.liveNow || $0.hasReplay }

    self.creatorLabelText = liveStreamEvent
      .map { Strings.project_creator_by_creator(creator_name: $0.creator.name) }

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.dateLabelText = liveStreamEvent
      .map { formattedDateString(date: $0.startDate) }

    self.nameLabelText = liveStreamEvent.map { $0.name }

    self.watchButtonHidden = self.countdownStackViewHidden.map(negate)

    let countdown = liveStreamEvent
      .switchMap { countdownProducer(to: $0.startDate) }

    self.dayCountLabelText = countdown.map { $0.day }.skipRepeats()
    self.hourCountLabelText = countdown.map { $0.hour }.skipRepeats()
    self.minuteCountLabelText = countdown.map { $0.minute }.skipRepeats()
    self.secondCountLabelText = countdown.map { $0.second }.skipRepeats()
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.liveStreamEventProperty.value = liveStreamEvent
  }

  public let backgroundImageUrl: Signal<URL?, NoError>
  public let countdownStackViewHidden: Signal<Bool, NoError>
  public let creatorImageUrl: Signal<URL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let dateLabelText: Signal<String, NoError>
  public let dayCountLabelText: Signal<String, NoError>
  public let hourCountLabelText: Signal<String, NoError>
  public let minuteCountLabelText: Signal<String, NoError>
  public let nameLabelText: Signal<String, NoError>
  public let secondCountLabelText: Signal<String, NoError>
  public let watchButtonHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamDiscoveryCellViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryCellViewModelOutputs { return self }
}

private func formattedDateString(date: Date) -> String {

  let format = DateFormatter.dateFormat(fromTemplate: "dMMMhmzzz",
                                        options: 0,
                                        locale: AppEnvironment.current.locale) ?? "MMM d, h:mm a zzz"

  let formatted = Format.date(secondsInUTC: date.timeIntervalSince1970,
                              dateFormat: format)

  return localizedString(
    key: "Live_stream_date",
    defaultValue: "Live stream – %{date}",
    substitutions: ["date": formatted]
  )
}
