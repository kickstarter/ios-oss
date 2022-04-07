import AVFoundation
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol VideoViewElementCellViewModelInputs {
  /// Call to configure with a `VideoViewElement` representing raw video view with an optional `AVPlayer` and `UIImage`` if its ready with its asset.
  func configureWith(element: VideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?)

  /// Call to send a pause signal to `AVPlayer` to pause the playing video and return a seek time.
  func pausePlayback() -> CMTime

  /// Call to record current playback seektime to resume playback later.
  func recordSeektime(_ seekTime: CMTime)
}

public protocol VideoViewElementCellViewModelOutputs {
  /// Emits a signal to pause playback of video
  var pauseVideo: Signal<Void, Never> { get }

  /// Emits an optional `UIImage` that is the thumbnail image for the video.
  var thumbnailImage: Signal<UIImage, Never> { get }

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
    self.videoItem = self.videoViewElementWithPlayerAndThumbnailProperty.signal
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
    self.thumbnailImage = self.videoViewElementWithPlayerAndThumbnailProperty.signal
      .skipNil()
      .switchMap { (element, _, thumbnailImage) -> SignalProducer<UIImage?, Never> in
        guard element.seekPosition == .zero else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: thumbnailImage)
      }
      .skipNil()
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

  fileprivate let videoViewElementWithPlayerAndThumbnailProperty =
    MutableProperty<(element: VideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?)?>(nil)
  public func configureWith(element: VideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?) {
    self.videoViewElementWithPlayerAndThumbnailProperty.value = (element, player, thumbnailImage)
  }

  public let pauseVideo: Signal<Void, Never>
  public let videoItem: Signal<AVPlayer, Never>
  public let thumbnailImage: Signal<UIImage, Never>

  public var inputs: VideoViewElementCellViewModelInputs { self }
  public var outputs: VideoViewElementCellViewModelOutputs { self }
}
