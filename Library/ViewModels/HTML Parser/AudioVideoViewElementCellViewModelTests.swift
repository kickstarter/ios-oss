import AVKit
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class AudioVideoViewElementCellViewModelTests: TestCase {
  private let vm: AudioVideoViewElementCellViewModelType = AudioVideoViewElementCellViewModel()

  private let pauseAudioVideo = TestObserver<Void, Never>()
  private let audioVideoItem = TestObserver<AVPlayer, Never>()
  private let thumbnailImage = TestObserver<UIImage, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pauseAudioVideo.observe(self.pauseAudioVideo.observer)
    self.vm.outputs.audioVideoItem.observe(self.audioVideoItem.observer)
    self.vm.outputs.thumbnailImage.observe(self.thumbnailImage.observer)
  }

  func testAudioVideoViewElementData_Success() {
    let expectedTime = CMTime(
      seconds: 123.4,
      preferredTimescale: CMTimeScale(1)
    )
    let expectedPlayer = AVPlayer()
    expectedPlayer.seek(to: expectedTime)

    let audioVideoViewElement = AudioVideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: expectedTime
    )

    self.vm.inputs.configureWith(element: audioVideoViewElement, player: expectedPlayer, thumbnailImage: nil)

    self.audioVideoItem.assertLastValue(expectedPlayer)
  }

  func testThumbnailImage_Success() {
    let thumbnailImage = UIImage(systemName: "camera")!
    let expectedPlayer = AVPlayer()

    let audioVideoViewElement = AudioVideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: .zero
    )

    self.vm.inputs
      .configureWith(element: audioVideoViewElement, player: expectedPlayer, thumbnailImage: thumbnailImage)

    self.thumbnailImage.assertLastValue(thumbnailImage)
  }

  func testPausePlaybackDataAndRecordSeektime_Success() {
    let expectedTime = CMTime(
      seconds: 123.4,
      preferredTimescale: CMTimeScale(1)
    )
    let expectedPlayer = AVPlayer()
    expectedPlayer.seek(to: expectedTime)

    let audioVideoViewElement = AudioVideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: expectedTime
    )

    self.vm.inputs.configureWith(element: audioVideoViewElement, player: expectedPlayer, thumbnailImage: nil)

    self.pauseAudioVideo.assertDidNotEmitValue()

    self.vm.inputs.recordSeektime(expectedTime)

    let recordedTime = self.vm.inputs.pausePlayback()

    self.pauseAudioVideo.assertDidEmitValue()

    XCTAssertEqual(recordedTime, expectedTime)
  }
}
