import AVFoundation
import OpenTok
import Prelude
import ReactiveCocoa
import Result

internal protocol LiveVideoViewModelInputs {
  func configureWith(hlsStreamUrl hlsStreamUrl: String)
  func configureWith(sessionConfig sessionConfig: OpenTokSessionConfig)
  func hlsPlayerStateChanged(state state: AVPlayerItemStatus)
  func viewDidLoad()
  func sessionDidConnect()
  func sessionDidFailWithError(error error: OTErrorType)
  func sessionStreamCreated(stream stream: OTStreamType)
  func sessionStreamDestroyed(stream stream: OTStreamType)
}

internal protocol LiveVideoViewModelOutputs {
  var addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError> { get }
  var addAndConfigureSubscriber: Signal<OTStreamType, NoError> { get }
  var createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError> { get }
  var playbackState: Signal<LiveVideoPlaybackState, NoError> { get }
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
    self.addAndConfigureHLSPlayerWithStreamUrl = self.hlsStreamUrlProperty.signal.ignoreNil()

    self.createAndConfigureSessionWithConfig = combineLatest(
      self.sessionConfigProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    self.addAndConfigureSubscriber = self.sessionStreamCreatedProperty.signal.ignoreNil()
    self.removeSubscriber = self.sessionStreamDestroyedProperty.signal.ignoreNil()

    self.playbackState = Signal.merge(
      self.hlsPlayerStateChangedProperty.signal.ignoreNil().map {
        switch $0 {
        case .Failed: return .error(error: .failedToConnect)
        case .Unknown: return .loading
        case .ReadyToPlay: return .playing
        }
      },
      self.sessionConfigProperty.signal.ignoreNil().mapConst(.loading),
      self.sessionDidConnectProperty.signal.mapConst(.playing),
      self.sessionDidFailWithErrorProperty.signal.ignoreNil().mapConst(.error(error: .sessionInterrupted))
    )

    self.removeAllVideoViews = Signal.merge(
      self.addAndConfigureHLSPlayerWithStreamUrl.skip(1).mapConst(()),
      self.playbackState.filter { if case .error = $0 { return true }; return false }.mapConst(())
    )
  }

  private let hlsStreamUrlProperty = MutableProperty<String?>(nil)
  internal func configureWith(hlsStreamUrl hlsStreamUrl: String) {
    self.hlsStreamUrlProperty.value = hlsStreamUrl
  }

  private let sessionConfigProperty = MutableProperty<OpenTokSessionConfig?>(nil)
  internal func configureWith(sessionConfig sessionConfig: OpenTokSessionConfig) {
    self.sessionConfigProperty.value = sessionConfig
  }

  private let hlsPlayerStateChangedProperty = MutableProperty<AVPlayerItemStatus?>(nil)
  internal func hlsPlayerStateChanged(state state: AVPlayerItemStatus) {
    self.hlsPlayerStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
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

  internal let addAndConfigureHLSPlayerWithStreamUrl: Signal<String, NoError>
  internal let addAndConfigureSubscriber: Signal<OTStreamType, NoError>
  internal let createAndConfigureSessionWithConfig: Signal<OpenTokSessionConfig, NoError>
  internal let playbackState: Signal<LiveVideoPlaybackState, NoError>
  internal let removeAllVideoViews: Signal<(), NoError>
  internal let removeSubscriber: Signal<OTStreamType, NoError>

  internal var inputs: LiveVideoViewModelInputs { return self }
  internal var outputs: LiveVideoViewModelOutputs { return self }
}
