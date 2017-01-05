import AVFoundation
import OpenTok
import Prelude
import ReactiveCocoa
import Result

internal typealias HlsStreamOrSessionConfig = Either<String, OpenTokSessionConfig>

internal protocol LiveVideoViewModelInputs {
  // FIXME: document these inputs
  func configureWith(hlsStreamOrSessionConfig hlsStreamOrSessionConfig: HlsStreamOrSessionConfig)
  func hlsPlayerStateChanged(state state: AVPlayerItemStatus)
  func sessionDidConnect()
  func sessionDidFailWithError(error error: OTErrorType)
  func sessionStreamCreated(stream stream: OTStreamType)
  func sessionStreamDestroyed(stream stream: OTStreamType)
  func viewDidLoad()
}

internal protocol LiveVideoViewModelOutputs {
  // FIXME: document these outputs
  var addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError> { get }
  var addAndConfigureSubscriber: Signal<OTStreamType, NoError> { get }
  var createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError> { get }
  var notifyDelegateOfPlaybackStateChange: Signal<LiveVideoPlaybackState, NoError> { get }
  var removeAllVideoViews: Signal<(), NoError> { get }
  var removeSubscriber: Signal<OTStreamType, NoError> { get }
}

internal protocol LiveVideoViewModelType {
  var inputs: LiveVideoViewModelInputs { get }
  var outputs: LiveVideoViewModelOutputs { get }
}

internal final class LiveVideoViewModel: LiveVideoViewModelType, LiveVideoViewModelInputs,
  LiveVideoViewModelOutputs {

  internal init() {
    let sessionConfig = self.configData.signal.ignoreNil()
      .map { $0.right }
      .ignoreNil()

    self.addAndConfigureHLSPlayerWithStreamUrl = self.configData.signal.ignoreNil()
      .map { $0.left }
      .ignoreNil()

    self.createAndConfigureSessionWithConfig = combineLatest(
      sessionConfig,
      self.viewDidLoadProperty.signal
      )
      .map(first)

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

    self.removeAllVideoViews = Signal.merge(
      // FIXME: confirm that configureWith gets called multiple times
      self.addAndConfigureHLSPlayerWithStreamUrl.skip(1).ignoreValues(),
      self.notifyDelegateOfPlaybackStateChange.filter { $0.isError }.ignoreValues()
    )
  }

  private let configData = MutableProperty<Either<String, OpenTokSessionConfig>?>(nil)
  internal func configureWith(hlsStreamOrSessionConfig hlsStreamOrSessionConfig: HlsStreamOrSessionConfig) {
    self.configData.value = hlsStreamOrSessionConfig
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
  internal let removeAllVideoViews: Signal<(), NoError>
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
