import AVFoundation
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol AudioVideoViewElementCellViewModelInputs {
  /// Call to configure with a `AudioVideoViewElement` representing raw audio/video view with an optional `AVPlayer` and `UIImage`` if its ready with its asset.
  func configureWith(element: AudioVideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?)

  /// Call to send a pause signal to `AVPlayer` to pause the playing audio/video and return a seek time.
  func pausePlayback() -> CMTime

  /// Call to record current playback seektime to resume playback later.
  func recordSeektime(_ seekTime: CMTime)
}

public protocol AudioVideoViewElementCellViewModelOutputs {
  /// Emits a signal to pause playback of audio/video
  var pauseAudioVideo: Signal<Void, Never> { get }

  /// Emits an optional `UIImage` that is the thumbnail image for the video.
  var thumbnailImage: Signal<UIImage, Never> { get }

  /// Emits an optional `AVPlayer` with an `AVPlayerItem` for audio/video view with a preset seektime if the element contained one.
  var audioVideoItem: Signal<AVPlayer, Never> { get }
}

public protocol AudioVideoViewElementCellViewModelType {
  var inputs: AudioVideoViewElementCellViewModelInputs { get }
  var outputs: AudioVideoViewElementCellViewModelOutputs { get }
}

public final class AudioVideoViewElementCellViewModel:
  AudioVideoViewElementCellViewModelType, AudioVideoViewElementCellViewModelInputs,
  AudioVideoViewElementCellViewModelOutputs {
  // MARK: Initializers

  public init() {
    self.audioVideoItem = self.audioVideoViewElementWithPlayerAndThumbnailProperty.signal
      .switchMap { audioVideoElementWithPlayer -> SignalProducer<AVPlayer?, Never> in
        guard let player = audioVideoElementWithPlayer?.player else {
          return SignalProducer(value: nil)
        }

        let seekTime = audioVideoElementWithPlayer?.element.seekPosition ?? .zero
        let validPlayTime = seekTime.isValid ? seekTime : .zero

        player.currentItem?.seek(to: validPlayTime, completionHandler: nil)

        return SignalProducer(value: player)
      }
      .skipNil()

    self.pauseAudioVideo = self.pausePlaybackProperty.signal.ignoreValues()
    self.thumbnailImage = self.audioVideoViewElementWithPlayerAndThumbnailProperty.signal
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

  fileprivate let audioVideoViewElementWithPlayerAndThumbnailProperty =
    MutableProperty<(element: AudioVideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?)?>(nil)
  public func configureWith(element: AudioVideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?) {
    self.audioVideoViewElementWithPlayerAndThumbnailProperty.value = (element, player, thumbnailImage)
  }

  public let pauseAudioVideo: Signal<Void, Never>
  public let audioVideoItem: Signal<AVPlayer, Never>
  public let thumbnailImage: Signal<UIImage, Never>

  public var inputs: AudioVideoViewElementCellViewModelInputs { self }
  public var outputs: AudioVideoViewElementCellViewModelOutputs { self }
}
