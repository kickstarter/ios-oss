import AVFoundation
import OpenTok
import Prelude
import ReactiveCocoa
import Result

internal protocol LiveVideoViewModelInputs {
  /// Call with the live stream given to the view.
  func configureWith(liveStreamType liveStreamType: LiveStreamType)

  /// Call when the HLS player's state changes.
  func hlsPlayerStateChanged(state state: AVPlayerItemStatus)

  /// Call when the OpenTok session connects.
  func sessionDidConnect()

  /// Call when the OpenTok session fails.
  func sessionDidFailWithError(error error: OTErrorType)

  /// Call when the OpenTok session stream is created.
  func sessionStreamCreated(stream stream: OTStreamType)

  /// Call when the OpenTok session is destroy.
  func sessionStreamDestroyed(stream stream: OTStreamType)

  /// Call when the view loads.
  func viewDidLoad()
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
}

internal protocol LiveVideoViewModelType {
  var inputs: LiveVideoViewModelInputs { get }
  var outputs: LiveVideoViewModelOutputs { get }
}

internal final class LiveVideoViewModel: LiveVideoViewModelType, LiveVideoViewModelInputs,
  LiveVideoViewModelOutputs {

  internal init() {
    let liveStreamType = combineLatest(
      self.liveStreamTypeProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let sessionConfig = liveStreamType
      .map { $0.openTokSessionConfig }
      .ignoreNil()

    self.addAndConfigureHLSPlayerWithStreamUrl = liveStreamType
      .map { $0.hlsStreamUrl }
      .ignoreNil()

    self.createAndConfigureSessionWithConfig = sessionConfig

    self.addAndConfigureSubscriber = self.sessionStreamCreatedProperty.signal.ignoreNil()
    self.removeSubscriber = self.sessionStreamDestroyedProperty.signal.ignoreNil()

    self.notifyDelegateOfPlaybackStateChange = Signal.merge(
      self.hlsPlayerStateChangedProperty.signal.ignoreNil()
        .map(playbackState(fromHlsPlayState:)),
      sessionConfig.mapConst(.loading),
      self.sessionDidConnectProperty.signal.mapConst(.playing),
      self.sessionDidFailWithErrorProperty.signal.ignoreNil()
        .mapConst(.error(error: .sessionInterrupted))
    )
  }

  private let liveStreamTypeProperty = MutableProperty<LiveStreamType?>(nil)
  internal func configureWith(liveStreamType liveStreamType: LiveStreamType) {
    self.liveStreamTypeProperty.value = liveStreamType
  }

  private let hlsPlayerStateChangedProperty = MutableProperty<AVPlayerItemStatus?>(nil)
  internal func hlsPlayerStateChanged(state state: AVPlayerItemStatus) {
    self.hlsPlayerStateChangedProperty.value = state
  }

  private let sessionDidConnectProperty = MutableProperty()
  internal func sessionDidConnect() {
    self.sessionDidConnectProperty.value = ()
  }

  private let sessionDidFailWithErrorProperty = MutableProperty<OTErrorType?>(nil)
  internal func sessionDidFailWithError(error error: OTErrorType) {
    self.sessionDidFailWithErrorProperty.value = error
  }

  private let sessionStreamCreatedProperty = MutableProperty<OTStreamType?>(nil)
  internal func sessionStreamCreated(stream stream: OTStreamType) {
    self.sessionStreamCreatedProperty.value = stream
  }

  private let sessionStreamDestroyedProperty = MutableProperty<OTStreamType?>(nil)
  internal func sessionStreamDestroyed(stream stream: OTStreamType) {
    self.sessionStreamDestroyedProperty.value = stream
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError>
  internal let addAndConfigureSubscriber: Signal<OTStreamType, NoError>
  internal let createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError>
  internal let notifyDelegateOfPlaybackStateChange: Signal<LiveVideoPlaybackState, NoError>
  internal let removeSubscriber: Signal<OTStreamType, NoError>

  internal var inputs: LiveVideoViewModelInputs { return self }
  internal var outputs: LiveVideoViewModelOutputs { return self }
}

private func playbackState(fromHlsPlayState state: AVPlayerItemStatus) -> LiveVideoPlaybackState {
  switch state {
  case .Failed: return .error(error: .failedToConnect)
  case .Unknown: return .loading
  case .ReadyToPlay: return .playing
  }
}
