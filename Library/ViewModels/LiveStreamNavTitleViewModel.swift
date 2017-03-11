import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamNavTitleViewModelType {
  var inputs: LiveStreamNavTitleViewModelInputs { get }
  var outputs: LiveStreamNavTitleViewModelOutputs { get }
}

public protocol LiveStreamNavTitleViewModelInputs {
  /// Call to configure with the live stream event.
  func configureWith(liveStreamEvent: LiveStreamEvent)

  /// Called to set the number of people watching the live stream.
  func setNumberOfPeopleWatching(numberOfPeople: Int)
}

public protocol LiveStreamNavTitleViewModelOutputs {
  /// Emits the text for the playback state label.
  var playbackStateLabelText: Signal<String, NoError> { get }

  /// Emits the background color for the playback state container.
  var playbackStateContainerBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits the hidden state of the number of people watching container.
  var numberOfPeopleWatchingContainerHidden: Signal<Bool, NoError> { get }

  /// Emits the formatted number of people watching text
  var numberOfPeopleWatchingLabelText: Signal<String, NoError> { get }
}

public final class LiveStreamNavTitleViewModel: LiveStreamNavTitleViewModelType,
LiveStreamNavTitleViewModelInputs, LiveStreamNavTitleViewModelOutputs {

  public init() {
    self.playbackStateLabelText = self.liveStreamEventProperty.signal.skipNil().map {
      $0.liveNow ? Strings.Live() : Strings.Recorded_Live()
    }

    self.playbackStateContainerBackgroundColor = self.liveStreamEventProperty.signal.skipNil().map {
      $0.liveNow ? .ksr_green_500 : UIColor.black.withAlphaComponent(0.4)
    }
    self.numberOfPeopleWatchingContainerHidden = self.liveStreamEventProperty.signal.skipNil()
      .map { $0.liveNow }
      .map(negate)

    self.numberOfPeopleWatchingLabelText = Signal.combineLatest(
      self.numberOfPeopleWatchingProperty.signal.skipNil()
        .map { Format.wholeNumber($0) },
      self.liveStreamEventProperty.signal.skipNil()
      )
      .map(first)
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.liveStreamEventProperty.value = liveStreamEvent
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  public func setNumberOfPeopleWatching(numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  public let playbackStateLabelText: Signal<String, NoError>
  public let playbackStateContainerBackgroundColor: Signal<UIColor, NoError>
  public let numberOfPeopleWatchingContainerHidden: Signal<Bool, NoError>
  public let numberOfPeopleWatchingLabelText: Signal<String, NoError>

  public var inputs: LiveStreamNavTitleViewModelInputs { return self }
  public var outputs: LiveStreamNavTitleViewModelOutputs { return self }
}
