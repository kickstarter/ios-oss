// swiftlint:disable type_name
import Prelude
import ReactiveSwift
import XCTest
@testable import KsApi
@testable import Library
@testable import LiveStream
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result

final class LiveStreamDiscoveryLiveNowCellViewModelTests: TestCase {
  let vm: LiveStreamDiscoveryLiveNowCellViewModelType = LiveStreamDiscoveryLiveNowCellViewModel()

  private let creatorImageUrl = TestObserver<URL?, NoError>()
  private let creatorLabelText = TestObserver<String, NoError>()
  private let playVideoUrl = TestObserver<URL?, NoError>()
  private let numberPeopleWatching = TestObserver<String, NoError>()
  private let stopVideo = TestObserver<(), NoError>()
  private let streamImageUrl = TestObserver<URL?, NoError>()
  private let streamTitleLabel = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.creatorImageUrl.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.playVideoUrl.observe(self.playVideoUrl.observer)
    self.vm.outputs.numberPeopleWatchingText.observe(self.numberPeopleWatching.observer)
    self.vm.outputs.stopVideo.observe(self.stopVideo.observer)
    self.vm.outputs.streamImageUrl.observe(self.streamImageUrl.observer)
    self.vm.outputs.streamTitleLabel.observe(self.streamTitleLabel.observer)
  }

  func testCreatorImageUrl() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.creator.avatar .~ "http://www.avatar.jpg"

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.creatorImageUrl.assertValues([URL(string: "http://www.avatar.jpg")])
  }

  func testCreatorLabelText() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.creator.name .~ "Blob McBlob"

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.creatorLabelText.assertValues(["<b>Blob McBlob</b> is live now"])
  }

  func testNumberPeopleWatchingText() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.numberPeopleWatching .~ 1500

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.numberPeopleWatching.assertValues(["1,500"])
  }

  func testNumberPeopleWatchingText_Unavailable() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.numberPeopleWatching .~ nil

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.numberPeopleWatching.assertValues(["0"])
  }

  func testPlayVideoUrl_ConfiguredEventDoesNotHaveHls() {
    let liveStreamEventWithoutHls = .template
      |> LiveStreamEvent.lens.hlsUrl .~ nil
    let liveStreamEventWithHls = liveStreamEventWithoutHls
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.site.com/vid.mp4"

    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEventWithHls))

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(liveStreamEvent: liveStreamEventWithoutHls)

      self.playVideoUrl.assertValues([])

      self.scheduler.advance()

      self.playVideoUrl.assertValues([URL(string: "http://www.site.com/vid.mp4")])
    }
  }

  func testPlayVideoUrl_ConfiguredEventHaHls() {
    let liveStreamEventWithHls = .template
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.site.com/vid.mp4"

    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEventWithHls))

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(liveStreamEvent: liveStreamEventWithHls)

      self.playVideoUrl.assertValues([URL(string: "http://www.site.com/vid.mp4")])

      self.scheduler.advance()

      self.playVideoUrl.assertValues([URL(string: "http://www.site.com/vid.mp4")])
    }
  }

  func testStopVideo() {
    self.vm.inputs.configureWith(liveStreamEvent: .template)

    self.stopVideo.assertValueCount(0)

    self.vm.inputs.didEndDisplay()

    self.stopVideo.assertValueCount(1)
  }
}
