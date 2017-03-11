import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamNavTitleViewModelTests: TestCase {
  let vm: LiveStreamNavTitleViewModelType = LiveStreamNavTitleViewModel()

  private let playbackStateLabelText = TestObserver<String, NoError>()
  private let playbackStateContainerBackgroundColor = TestObserver<UIColor, NoError>()
  private let numberOfPeopleWatchingContainerHidden = TestObserver<Bool, NoError>()
  private let numberOfPeopleWatchingLabelText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.playbackStateLabelText.observe(self.playbackStateLabelText.observer)
    self.vm.outputs.playbackStateContainerBackgroundColor.observe(
      self.playbackStateContainerBackgroundColor.observer)
    self.vm.outputs.numberOfPeopleWatchingContainerHidden.observe(
      self.numberOfPeopleWatchingContainerHidden.observer)
    self.vm.outputs.numberOfPeopleWatchingLabelText.observe(
      self.numberOfPeopleWatchingLabelText.observer)
  }

  func testPlaybackStateLabelText_Live() {
    self.playbackStateLabelText.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.playbackStateLabelText.assertValues(["Live"])
  }

  func testPlaybackStateLabelText_Replay() {
    self.playbackStateLabelText.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.playbackStateLabelText.assertValues(["Recorded Live"])
  }

  func testPlaybackStateContainerBackgroundColor_Live() {
    self.playbackStateContainerBackgroundColor.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.playbackStateContainerBackgroundColor.assertValues([.ksr_green_500])
  }

  func testPlaybackStateContainerBackgroundColor_Replay() {
    self.playbackStateContainerBackgroundColor.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.playbackStateContainerBackgroundColor.assertValues([UIColor.black.withAlphaComponent(0.4)])
  }

  func testNumberOfPeopleWatchingContainerHidden_Live() {
    self.numberOfPeopleWatchingContainerHidden.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.numberOfPeopleWatchingContainerHidden.assertValues([false])
  }

  func testNumberOfPeopleWatchingContainerHidden_Replay() {
    self.numberOfPeopleWatchingContainerHidden.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)

    self.numberOfPeopleWatchingContainerHidden.assertValues([true])
  }

  func testNumberOfPeopleWatchingLabelText() {
    self.numberOfPeopleWatchingLabelText.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent)
    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 2500)

    self.numberOfPeopleWatchingLabelText.assertValues(["2,500"])
  }

}
