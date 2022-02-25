import AVFoundation
import KsApi
import Prelude
import ReactiveSwift

public protocol VideoViewElementCellViewModelInputs {
  /// Call to configure with a `VideoViewElement` representing raw video view with an optional `AVPlayerItem` if its ready.
  func configureWith(element: VideoViewElement, item: AVPlayerItem?)

  /// Call to send a pause signal to `AVPlayer` to pause the playing video and return a seek time.
  func pausePlayback() -> CMTime

  /// Call to record current playback seektime to resume playback later.
  func recordSeektime(_ seekTime: CMTime)
}

public protocol VideoViewElementCellViewModelOutputs {
  /// Emits a signal to pause playback of video
  var pauseVideo: Signal<Void, Never> { get }

  /// Return this value once the observed `AVPlayerItem` is in a ready to play state.
  var videoPlayer: MutableProperty<AVPlayer?> { get }

  /// Emits a signal to set the playback seek time of video
  var seekTime: Signal<CMTime, Never> { get }

  /// Emits an optional `AVPlayer` with an `AVPlayerItem` for video view
  var videoItem: Signal<AVPlayer?, Never> { get }
}

public protocol VideoViewElementCellViewModelType {
  var inputs: VideoViewElementCellViewModelInputs { get }
  var outputs: VideoViewElementCellViewModelOutputs { get }
}

public final class VideoViewElementCellViewModel:
  VideoViewElementCellViewModelType, VideoViewElementCellViewModelInputs,
  VideoViewElementCellViewModelOutputs {
  // MARK: Properties

  private var kvoToken: NSKeyValueObservation?

  // MARK: Helpers

  public init() {
    self.videoItem = self.videoPlayer.signal

    let seekPosition = self.videoViewElementWithPlayerItem.signal
      .switchMap { elementAndItem -> SignalProducer<CMTime, Never> in
        guard let seekPosition = elementAndItem?.element.seekPosition else {
          return SignalProducer(value: .zero)
        }

        return SignalProducer(value: seekPosition)
      }

    self.pauseVideo = self.pausePlaybackProperty.signal.ignoreValues()
    self.seekTime = seekPosition

    let playerItemObservation: (AVPlayerItem) -> Void = { playerItem in
      var player: AVPlayer?

      self.kvoToken = playerItem.observe(\.status, options: [.new, .old]) { playerItem, change in
        guard let changeValue = change.newValue,
          let oldValue = change.oldValue,
          let newStatus = AVPlayerItem.Status(rawValue: changeValue.rawValue),
          let oldStatus = AVPlayerItem.Status(rawValue: oldValue.rawValue) else { return }

        switch (oldStatus, newStatus) {
        case (.readyToPlay, .readyToPlay):
          self.videoPlayer <~ SignalProducer(value: nil)
        case (_, .readyToPlay):
          player = AVPlayer(playerItem: playerItem)

          self.videoPlayer <~ SignalProducer(value: player)
        default:
          self.videoPlayer <~ SignalProducer(value: nil)
        }
      }
    }

    _ = self.videoViewElementWithPlayerItem.signal
      .on(value: { elementAndItem in
        guard let playerItem = elementAndItem?.item else { return }

        playerItemObservation(playerItem)
      })
  }

  // MARK: Deinitializers

  deinit {
    kvoToken?.invalidate()
  }

  fileprivate let pausePlaybackProperty = MutableProperty<Void>(())
  public func pausePlayback() -> CMTime {
    self.pausePlaybackProperty.value = ()

    return self.seekTimeProperty.value
  }

  fileprivate let playButtonTappedProperty = MutableProperty(())
  public func playButtonTapped() {
    self.playButtonTappedProperty.value = ()
  }

  fileprivate let seekTimeProperty = MutableProperty<CMTime>(.zero)
  public func recordSeektime(_ seekTime: CMTime) {
    self.seekTimeProperty.value = seekTime
  }

  fileprivate let videoViewElementWithPlayerItem =
    MutableProperty<(element: VideoViewElement, item: AVPlayerItem?)?>(nil)
  public func configureWith(element: VideoViewElement, item: AVPlayerItem?) {
    self.videoViewElementWithPlayerItem.value = (element, item)
  }

  public let pauseVideo: Signal<Void, Never>
  public let seekTime: Signal<CMTime, Never>
  public let videoItem: Signal<AVPlayer?, Never>
  public let videoPlayer = MutableProperty<AVPlayer?>(nil)

  public var inputs: VideoViewElementCellViewModelInputs { self }
  public var outputs: VideoViewElementCellViewModelOutputs { self }
}
