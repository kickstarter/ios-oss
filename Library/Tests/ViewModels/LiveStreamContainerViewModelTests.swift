import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamContainerViewModelTests: TestCase {
  private let vm: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  private let createAndConfigureLiveStreamViewController = TestObserver<(Project, LiveStreamEvent), NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let error = TestObserver<String, NoError>()
  private let liveStreamState = TestObserver<LiveStreamViewControllerState, NoError>()
  private let loaderText = TestObserver<String, NoError>()
  private let projectImageUrl = TestObserver<NSURL, NoError>()
  private let showVideoView = TestObserver<Bool, NoError>()
  private let titleViewText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.createAndConfigureLiveStreamViewController.observe(
      self.createAndConfigureLiveStreamViewController.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.error.observe(self.error.observer)
    self.vm.outputs.liveStreamState.observe(self.liveStreamState.observer)
    self.vm.outputs.loaderText.observe(self.loaderText.observer)
    self.vm.outputs.projectImageUrl.observe(self.projectImageUrl.observer)
    self.vm.outputs.showVideoView.observe(self.showVideoView.observer)
    self.vm.outputs.titleViewText.observe(self.titleViewText.observer)
  }

  func testCreateLiveStreamViewController() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    XCTAssertTrue(self.createAndConfigureLiveStreamViewController.lastValue == (project, event))
  }

  func testDismiss() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testError() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .sessionInterrupted), startTime: 0))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .failedToConnect), startTime: 0))

    self.error.assertValues([
      "The live stream was interrupted",
      "The live stream failed to connect"
    ])
  }

  func testLiveStreamStates() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .loading, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .sessionInterrupted), startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .error(error: .failedToConnect),
        duration: 123))

    // Test begins with an implicit loading state before any others
    self.liveStreamState.assertValues([
      .loading,
      .greenRoom,
      .loading,
      .live(playbackState: .loading, startTime: 123),
      .live(playbackState: .playing, startTime: 123),
      .live(playbackState: .error(error: .sessionInterrupted), startTime: 123),
      .replay(playbackState: .loading, duration: 123),
      .replay(playbackState: .playing, duration: 123),
      .replay(playbackState: .error(error: .failedToConnect), replayAvailable: false, duration: 123)
    ])
  }

  func testLoaderText() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))

    self.loaderText.assertValues([
      "Loading",
      "The live stream will start soon",
      "Loading",
      "The replay will start soon"
    ])
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, event: nil)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.projectImageUrl.lastValue?.absoluteString == "http://www.kickstarter.com/full.jpg")
  }

  func testShowVideoView() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123))

    self.showVideoView.assertValues([
      false,
      false,
      true,
      false,
      true
    ])
  }

  func testTitleViewText() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .loading, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))

    self.titleViewText.assertValues([
      "Loading",
      "Starting soon",
      "Live",
      "Loading",
      "Recorded Live"
    ])
  }
}

private func == (tuple1: (Project, LiveStreamEvent)?, tuple2: (Project, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
