import AVKit
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class VideoViewElementCellViewModelTests: TestCase {
  private let vm: VideoViewElementCellViewModelType = VideoViewElementCellViewModel()

  private let pauseVideo = TestObserver<Void, Never>()
  private let videoItem = TestObserver<AVPlayer, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pauseVideo.observe(self.pauseVideo.observer)
    self.vm.outputs.videoItem.observe(self.videoItem.observer)
  }

  func testImageViewElementData_Success() {
    let expectedTime = CMTime(
      seconds: 123.4,
      preferredTimescale: CMTimeScale(1)
    )
    let expectedPlayer = AVPlayer()
    expectedPlayer.seek(to: expectedTime)

    let videoViewElement = VideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: expectedTime
    )

    self.vm.inputs.configureWith(element: videoViewElement, player: expectedPlayer)

    self.videoItem.assertLastValue(expectedPlayer)
  }

  func testPausePlaybackDataAndRecordSeektime_Success() {
    let expectedTime = CMTime(
      seconds: 123.4,
      preferredTimescale: CMTimeScale(1)
    )
    let expectedPlayer = AVPlayer()
    expectedPlayer.seek(to: expectedTime)

    let videoViewElement = VideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: expectedTime
    )

    self.vm.inputs.configureWith(element: videoViewElement, player: expectedPlayer)

    self.pauseVideo.assertDidNotEmitValue()

    self.vm.inputs.recordSeektime(expectedTime)

    let recordedTime = self.vm.inputs.pausePlayback()

    self.pauseVideo.assertDidEmitValue()

    XCTAssertEqual(recordedTime, expectedTime)
  }
}
