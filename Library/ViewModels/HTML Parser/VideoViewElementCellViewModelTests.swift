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
  private let thumbnailImage = TestObserver<UIImage, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pauseVideo.observe(self.pauseVideo.observer)
    self.vm.outputs.videoItem.observe(self.videoItem.observer)
  }

  func testVideoViewElementData_Success() {
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

    self.vm.inputs.configureWith(element: videoViewElement, player: expectedPlayer, thumbnailImage: nil)

    self.videoItem.assertLastValue(expectedPlayer)
  }

  func testThumbnailImage_Success() {
    let thumbnailImage = UIImage(systemName: "camera")!
    let expectedPlayer = AVPlayer()

    let videoViewElement = VideoViewElement(
      sourceURLString: "https://video.com",
      thumbnailURLString: "https://thumbnail.com",
      seekPosition: .zero
    )

    self.vm.inputs
      .configureWith(element: videoViewElement, player: expectedPlayer, thumbnailImage: thumbnailImage)

    self.thumbnailImage.assertLastValue(thumbnailImage)
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

    self.vm.inputs.configureWith(element: videoViewElement, player: expectedPlayer, thumbnailImage: nil)

    self.pauseVideo.assertDidNotEmitValue()

    self.vm.inputs.recordSeektime(expectedTime)

    let recordedTime = self.vm.inputs.pausePlayback()

    self.pauseVideo.assertDidEmitValue()

    XCTAssertEqual(recordedTime, expectedTime)
  }
}
