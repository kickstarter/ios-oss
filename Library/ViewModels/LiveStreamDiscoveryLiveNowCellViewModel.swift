import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryLiveNowCellViewModelInputs {
  /// Call with the config data given to the view.
  func configureWith(liveStreamEvent: LiveStreamEvent)

  /// Call when the cell ends displaying in the view.
  func didEndDisplay()
}

public protocol LiveStreamDiscoveryLiveNowCellViewModelOutputs {
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var playVideoUrl: Signal<URL?, NoError> { get }
  var numberPeopleWatchingHidden: Signal<Bool, NoError> { get }
  var numberPeopleWatchingText: Signal<String, NoError> { get }
  var stopVideo: Signal<(), NoError> { get }
  var streamImageUrl: Signal<URL?, NoError> { get }
  var streamTitleLabel: Signal<String, NoError> { get }
}

public protocol LiveStreamDiscoveryLiveNowCellViewModelType {
  var inputs: LiveStreamDiscoveryLiveNowCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryLiveNowCellViewModelOutputs { get }
}

public final class LiveStreamDiscoveryLiveNowCellViewModel: LiveStreamDiscoveryLiveNowCellViewModelType,
LiveStreamDiscoveryLiveNowCellViewModelInputs, LiveStreamDiscoveryLiveNowCellViewModelOutputs {

  public init() {
    let liveStreamEvent = self.configData.signal.skipNil()

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.playVideoUrl = liveStreamEvent
      .switchMap { event in
        AppEnvironment.current.liveStreamService.fetchEvent(eventId: event.id, uid: nil)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .prefix(value: event)
          .map { $0.hlsUrl.map(URL.init(string:)) }
          .skipNil()
          .take(first: 1)
    }

    self.creatorLabelText = liveStreamEvent
      .map { Strings.Creator_name_is_live_now(creator_name: $0.creator.name) }

    self.numberPeopleWatchingHidden = liveStreamEvent.map { $0.numberPeopleWatching == nil }

    self.numberPeopleWatchingText = liveStreamEvent.map {
      Format.wholeNumber($0.numberPeopleWatching.coalesceWith(0))
    }

    self.streamTitleLabel = liveStreamEvent
      .map { $0.name }

    self.streamImageUrl = liveStreamEvent
      .map { URL.init(string: $0.backgroundImage.medium) }

    self.stopVideo = self.didEndDisplayProperty.signal
  }

  private let configData = MutableProperty<LiveStreamEvent?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.configData.value = liveStreamEvent
  }

  private let didEndDisplayProperty = MutableProperty()
  public func didEndDisplay() {
    self.didEndDisplayProperty.value = ()
  }

  public let creatorImageUrl: Signal<URL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let playVideoUrl: Signal<URL?, NoError>
  public let numberPeopleWatchingHidden: Signal<Bool, NoError>
  public let numberPeopleWatchingText: Signal<String, NoError>
  public let stopVideo: Signal<(), NoError>
  public let streamImageUrl: Signal<URL?, NoError>
  public let streamTitleLabel: Signal<String, NoError>

  public var inputs: LiveStreamDiscoveryLiveNowCellViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryLiveNowCellViewModelOutputs { return self }
}
