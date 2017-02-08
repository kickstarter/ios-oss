import AVFoundation
import OpenTok
import Prelude
import ReactiveSwift
import Result

internal protocol LiveVideoViewModelInputs {
  /// Call with the live stream given to the view.
  func configureWith(liveStreamType: LiveStreamType)

  /// Call when the HLS player's state changes.
  func hlsPlayerStateChanged(state: AVPlayerItemStatus)

  /// Call when the OpenTok session connects.
  func sessionDidConnect()

  /// Call when the OpenTok session fails.
  func sessionDidFailWithError(error: OTErrorType)

  /// Call when the OpenTok session stream is created.
  func sessionStreamCreated(stream: OTStreamType)

  /// Call when the OpenTok session is destroy.
  func sessionStreamDestroyed(stream: OTStreamType)

  /// Call when the view disappears.
  func viewDidDisappear()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()
}

internal protocol LiveVideoViewModelOutputs {
  /// Emits when the HLS player should be created and configured.
  var addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError> { get }

  /// Emits a OpenTok stream when a subscriber should be created and added to the stream.
  var addAndConfigureSubscriber: Signal<OTStreamType, NoError> { get }

  /// Emits an OpenTok session configuration when a session should be created and configured.
  var createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError> { get }

  /// Emits a playback state when the view should notify its delegate that the state changed.
  var notifyDelegateOfPlaybackStateChange: Signal<LiveVideoPlaybackState, NoError> { get }

  /// Emits a stream when the subscriber of that stream should be removed.
  var removeSubscriber: Signal<OTStreamType, NoError> { get }

  /// Emits when all subscribers should be re-subscribed when the view reappears.
  var resubscribeAllSubscribersToSession: Signal<(), NoError> { get }

  /// Emits to toggle play/pause when the view disappears/reappears.
  var shouldPauseHlsPlayer: Signal<Bool, NoError> { get }

  /// Emits when all subscribers should be unsubscribed when the view disappears.
  var unsubscribeAllSubscribersFromSession: Signal<(), NoError> { get }
}

internal protocol LiveVideoViewModelType {
  var inputs: LiveVideoViewModelInputs { get }
  var outputs: LiveVideoViewModelOutputs { get }
}

internal final class LiveVideoViewModel: LiveVideoViewModelType, LiveVideoViewModelInputs,
  LiveVideoViewModelOutputs {

  internal init() {
    let liveStreamType = Signal.combineLatest(
      self.liveStreamTypeProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let openTokSessionConfig = liveStreamType
      .map { $0.openTokSessionConfig }
      .skipNil()

    self.addAndConfigureHLSPlayerWithStreamUrl = liveStreamType
      .map { $0.hlsStreamUrl }
      .skipNil()

    self.createAndConfigureSessionWithConfig = openTokSessionConfig

    self.addAndConfigureSubscriber = self.sessionStreamCreatedProperty.signal.skipNil()
    self.removeSubscriber = self.sessionStreamDestroyedProperty.signal.skipNil()

    self.notifyDelegateOfPlaybackStateChange = Signal.merge(
      self.hlsPlayerStateChangedProperty.signal.skipNil()
        .map(playbackState(fromHlsPlayState:)),

      self.addAndConfigureHLSPlayerWithStreamUrl.mapConst(.loading),

      openTokSessionConfig.mapConst(.loading),

      self.sessionDidConnectProperty.signal.mapConst(.playing),

      self.sessionDidFailWithErrorProperty.signal.skipNil()
        .mapConst(.error(error: .sessionInterrupted))
    )

    let viewReappeared = self.viewWillAppearProperty.signal.skip(first: 1)

    self.shouldPauseHlsPlayer = Signal.combineLatest(
      Signal.merge(
        self.viewDidDisappearProperty.signal.mapConst(true),
        viewReappeared.mapConst(false)
      ),
      self.addAndConfigureHLSPlayerWithStreamUrl.signal
    ).map(first)

    self.unsubscribeAllSubscribersFromSession = Signal.combineLatest(
      self.viewDidDisappearProperty.signal,
      createAndConfigureSessionWithConfig
    ).ignoreValues()

    self.resubscribeAllSubscribersToSession = Signal.combineLatest(
      viewReappeared,
      createAndConfigureSessionWithConfig
    ).ignoreValues()
  }

  private let liveStreamTypeProperty = MutableProperty<LiveStreamType?>(nil)
  internal func configureWith(liveStreamType: LiveStreamType) {
    self.liveStreamTypeProperty.value = liveStreamType
  }

  private let hlsPlayerStateChangedProperty = MutableProperty<AVPlayerItemStatus?>(nil)
  internal func hlsPlayerStateChanged(state: AVPlayerItemStatus) {
    self.hlsPlayerStateChangedProperty.value = state
  }

  private let sessionDidConnectProperty = MutableProperty()
  internal func sessionDidConnect() {
    self.sessionDidConnectProperty.value = ()
  }

  private let sessionDidFailWithErrorProperty = MutableProperty<OTErrorType?>(nil)
  internal func sessionDidFailWithError(error: OTErrorType) {
    self.sessionDidFailWithErrorProperty.value = error
  }

  private let sessionStreamCreatedProperty = MutableProperty<OTStreamType?>(nil)
  internal func sessionStreamCreated(stream: OTStreamType) {
    self.sessionStreamCreatedProperty.value = stream
  }

  private let sessionStreamDestroyedProperty = MutableProperty<OTStreamType?>(nil)
  internal func sessionStreamDestroyed(stream: OTStreamType) {
    self.sessionStreamDestroyedProperty.value = stream
  }

  private let viewDidDisappearProperty = MutableProperty()
  internal func viewDidDisappear() {
    self.viewDidDisappearProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  internal let addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError>
  internal let addAndConfigureSubscriber: Signal<OTStreamType, NoError>
  internal let createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError>
  internal let notifyDelegateOfPlaybackStateChange: Signal<LiveVideoPlaybackState, NoError>
  internal let removeSubscriber: Signal<OTStreamType, NoError>
  internal let resubscribeAllSubscribersToSession: Signal<(), NoError>
  internal let shouldPauseHlsPlayer: Signal<Bool, NoError>
  internal let unsubscribeAllSubscribersFromSession: Signal<(), NoError>

  internal var inputs: LiveVideoViewModelInputs { return self }
  internal var outputs: LiveVideoViewModelOutputs { return self }
}

private func playbackState(fromHlsPlayState state: AVPlayerItemStatus) -> LiveVideoPlaybackState {
  switch state {
  case .failed: return .error(error: .failedToConnect)
  case .unknown: return .loading
  case .readyToPlay: return .playing
  }
}
