import AVFoundation
import KsApi
import Prelude
import ReactiveSwift

public protocol VideoViewElementCellViewModelInputs {
  /// Call to configure with a `VideoViewElement` representing raw video view with an optional `AVPlayer` if its ready with its asset.
  func configureWith(element: VideoViewElement, player: AVPlayer?)

  /// Call to send a pause signal to `AVPlayer` to pause the playing video and return a seek time.
  func pausePlayback() -> CMTime

  /// Call to record current playback seektime to resume playback later.
  func recordSeektime(_ seekTime: CMTime)
}

public protocol VideoViewElementCellViewModelOutputs {
  /// Emits a signal to pause playback of video
  var pauseVideo: Signal<Void, Never> { get }

  /// Emits an optional `AVPlayer` with an `AVPlayerItem` for video view with a preset seektime if the element contained one.
  var videoItem: Signal<AVPlayer, Never> { get }
}

public protocol VideoViewElementCellViewModelType {
  var inputs: VideoViewElementCellViewModelInputs { get }
  var outputs: VideoViewElementCellViewModelOutputs { get }
}

public final class VideoViewElementCellViewModel:
  VideoViewElementCellViewModelType, VideoViewElementCellViewModelInputs,
  VideoViewElementCellViewModelOutputs {
  // MARK: Initializers

  public init() {
    self.videoItem = self.videoViewElementWithPlayer.signal
      .switchMap { videoElementWithPlayer -> SignalProducer<AVPlayer?, Never> in
        guard let player = videoElementWithPlayer?.player else {
          return SignalProducer(value: nil)
        }

        let seekTime = videoElementWithPlayer?.element.seekPosition ?? .zero
        let validPlayTime = seekTime.isValid ? seekTime : .zero

        player.currentItem?.seek(to: validPlayTime, completionHandler: nil)

        return SignalProducer(value: player)
      }
      .skipNil()

    self.pauseVideo = self.pausePlaybackProperty.signal.ignoreValues()
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

  fileprivate let videoViewElementWithPlayer =
    MutableProperty<(element: VideoViewElement, player: AVPlayer?)?>(nil)
  public func configureWith(element: VideoViewElement, player: AVPlayer?) {
    self.videoViewElementWithPlayer.value = (element, player)
  }

  public let pauseVideo: Signal<Void, Never>
  public let videoItem: Signal<AVPlayer, Never>

  public var inputs: VideoViewElementCellViewModelInputs { self }
  public var outputs: VideoViewElementCellViewModelOutputs { self }
}
