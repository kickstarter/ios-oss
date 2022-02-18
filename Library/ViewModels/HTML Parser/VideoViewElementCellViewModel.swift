import AVFoundation
import KsApi
import Prelude
import ReactiveSwift

public protocol VideoViewElementCellViewModelInputs {
  /// Call to configure with a VideoViewElement representing raw HTML
  func configureWith(videoElement: VideoViewElement)

  /// Call to hide the play button and send a signal to AVPlayer to start playing the video
  func playButtonTapped()

  /// Call to send a pause signal to AVPlayer to pause the playing video and return a seek time.
  func pausePlayback() -> CMTime

  /// Call to record current playback seektime to resume playback later.
  func recordSeektime(_ seekTime: CMTime)
}

public protocol VideoViewElementCellViewModelOutputs {
  /// Emits a video url for video view
  var videoURL: Signal<URL, Never> { get }

  /// Emits a boolean to determine whether or not the play button should be hidden.
  var playButtonHidden: Signal<Bool, Never> { get }

  /// Emits a seek position to start playback of video
  var playVideo: Signal<Void, Never> { get }

  /// Emits a signal to pause playback of video
  var pauseVideo: Signal<Void, Never> { get }

  /// Emits a signal to set the playback seek time of video
  var seekTime: Signal<CMTime, Never> { get }
}

public protocol VideoViewElementCellViewModelType {
  var inputs: VideoViewElementCellViewModelInputs { get }
  var outputs: VideoViewElementCellViewModelOutputs { get }
}

public final class VideoViewElementCellViewModel:
  VideoViewElementCellViewModelType, VideoViewElementCellViewModelInputs,
  VideoViewElementCellViewModelOutputs {
  // MARK: Helpers

  public init() {
    self.videoURL = self.videoElement.signal
      .switchMap { videoViewElement -> SignalProducer<URL?, Never> in
        guard let element = videoViewElement,
          let url = URL(string: element.sourceUrlString) else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: url)
      }
      .skipNil()

    let seekPosition = self.videoElement.signal
      .switchMap { element -> SignalProducer<CMTime, Never> in
        guard let seekPosition = element?.seekPosition else {
          return SignalProducer(value: .zero)
        }

        return SignalProducer(value: seekPosition)
      }

    self.playButtonHidden = self.playButtonTappedProperty.signal.mapConst(true)
    self.playVideo = self.playButtonTappedProperty.signal
    self.pauseVideo = self.pausePlaybackProperty.signal.ignoreValues()
    self.seekTime = seekPosition
  }

  fileprivate let videoElement = MutableProperty<VideoViewElement?>(nil)
  public func configureWith(videoElement: VideoViewElement) {
    self.videoElement.value = videoElement
  }

  fileprivate let playButtonTappedProperty = MutableProperty(())
  public func playButtonTapped() {
    self.playButtonTappedProperty.value = ()
  }

  fileprivate let pausePlaybackProperty = MutableProperty<Void>(())
  public func pausePlayback() -> CMTime {
    self.pausePlaybackProperty.value = ()

    return self.seekTimeProperty.value
  }

  fileprivate let seekTimeProperty = MutableProperty<CMTime>(.zero)
  public func recordSeektime(_ seekTime: CMTime) {
    self.seekTimeProperty.value = seekTime
  }

  public let videoURL: Signal<URL, Never>
  public let playButtonHidden: Signal<Bool, Never>
  public let playVideo: Signal<Void, Never>
  public let pauseVideo: Signal<Void, Never>
  public let seekTime: Signal<CMTime, Never>

  public var inputs: VideoViewElementCellViewModelInputs { self }
  public var outputs: VideoViewElementCellViewModelOutputs { self }
}
