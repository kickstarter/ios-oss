import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryUpcomingAndReplayCellViewModelInputs {
  func configureWith(liveStreamEvent: LiveStreamEvent)
}

public protocol LiveStreamDiscoveryUpcomingAndReplayCellViewModelOutputs {
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var dateContainerViewHidden: Signal<Bool, NoError> { get }
  var dateLabelText: Signal<String, NoError> { get }
  var imageOverlayColor: Signal<UIColor, NoError> { get }
  var replayButtonHidden: Signal<Bool, NoError> { get }
  var streamAvailabilityLabelHidden: Signal<Bool, NoError> { get }
  var streamAvailabilityLabelText: Signal<String, NoError> { get }
  var streamImageUrl: Signal<URL?, NoError> { get }
  var streamTitleLabelText: Signal<String, NoError> { get }
}

public protocol LiveStreamDiscoveryUpcomingAndReplayCellViewModelType {
  var inputs: LiveStreamDiscoveryUpcomingAndReplayCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryUpcomingAndReplayCellViewModelOutputs { get }
}

public final class LiveStreamDiscoveryUpcomingAndReplayCellViewModel:
LiveStreamDiscoveryUpcomingAndReplayCellViewModelType,
LiveStreamDiscoveryUpcomingAndReplayCellViewModelInputs,
LiveStreamDiscoveryUpcomingAndReplayCellViewModelOutputs {

  public init() {
    let liveStreamEvent = self.configData.signal.skipNil()

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.streamImageUrl = liveStreamEvent
      .map { URL(string: $0.backgroundImage.smallCropped) }

    self.streamTitleLabelText = liveStreamEvent
      .map { $0.name }

    self.imageOverlayColor = liveStreamEvent
      .map {
        $0.hasReplay == .some(true)
          ? UIColor.hex(0x353535)
          : UIColor.ksr_navy_900
    }

    self.creatorLabelText = liveStreamEvent
      .map {
        $0.hasReplay == .some(true)
          ? localizedString(key: "Replay_live_stream_with_creator_name",
                            defaultValue: "Replay live stream with<br><b>%{creator_name}</b>",
                            substitutions: ["creator_name": $0.creator.name])
          : Strings.Upcoming_with_creator_name(creator_name: $0.creator.name)
    }

    self.dateLabelText = liveStreamEvent
      .map { formattedDateString(date: $0.startDate) }

    self.replayButtonHidden = liveStreamEvent
      .map { $0.hasReplay != .some(true) }

    self.streamAvailabilityLabelText = liveStreamEvent
      .map(availabilityText(forLiveStreamEvent:))

    self.streamAvailabilityLabelHidden = self.replayButtonHidden

    self.dateContainerViewHidden = self.replayButtonHidden.map(negate)
  }

  private let configData = MutableProperty<LiveStreamEvent?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.configData.value = liveStreamEvent
  }

  public let creatorImageUrl: Signal<URL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let dateContainerViewHidden: Signal<Bool, NoError>
  public let dateLabelText: Signal<String, NoError>
  public let imageOverlayColor: Signal<UIColor, NoError>
  public let replayButtonHidden: Signal<Bool, NoError>
  public let streamAvailabilityLabelHidden: Signal<Bool, NoError>
  public let streamAvailabilityLabelText: Signal<String, NoError>
  public let streamImageUrl: Signal<URL?, NoError>
  public let streamTitleLabelText: Signal<String, NoError>

  public var inputs: LiveStreamDiscoveryUpcomingAndReplayCellViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryUpcomingAndReplayCellViewModelOutputs { return self }
}

private func availabilityText(forLiveStreamEvent event: LiveStreamEvent) -> String {
  guard let availableDate = AppEnvironment.current.calendar
    .date(byAdding: .day, value: 2, to: event.startDate)?.timeIntervalSince1970
    else { return "" }

  let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

  return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
}

private func formattedDateString(date: Date) -> String {

  let format = DateFormatter.dateFormat(fromTemplate: "dMMMhmzzz",
                                        options: 0,
                                        locale: AppEnvironment.current.locale) ?? "MMM d, h:mm a zzz"

  return Format.date(secondsInUTC: date.timeIntervalSince1970, dateFormat: format)
}
