import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamContainerViewModelTests: TestCase {
  private let vm: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  private let availableForLabelHidden = TestObserver<Bool, NoError>()
  private let availableForText = TestObserver<String, NoError>()
  private let createAndConfigureLiveStreamViewController = TestObserver<(Project, Int?,
    LiveStreamEvent), NoError>()
  private let creatorAvatarLiveDotImageViewHidden = TestObserver<Bool, NoError>()
  private let creatorIntroText = TestObserver<String, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let loaderStackViewHidden = TestObserver<Bool, NoError>()
  private let loaderText = TestObserver<String, NoError>()
  private let navBarTitleViewHidden = TestObserver<Bool, NoError>()
  private let navBarLiveDotImageViewHidden = TestObserver<Bool, NoError>()
  private let numberWatchingBadgeViewHidden = TestObserver<Bool, NoError>()
  private let projectImageUrlString = TestObserver<String?, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let videoViewControllerHidden = TestObserver<Bool, NoError>()
  private let titleViewText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForLabelHidden.observe(self.availableForLabelHidden.observer)
    self.vm.outputs.availableForText.observe(self.availableForText.observer)
    self.vm.outputs.createAndConfigureLiveStreamViewController.observe(
      self.createAndConfigureLiveStreamViewController.observer)
    self.vm.outputs.creatorAvatarLiveDotImageViewHidden
      .observe(self.creatorAvatarLiveDotImageViewHidden.observer)
    self.vm.outputs.creatorIntroText.observe(self.creatorIntroText.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.loaderStackViewHidden.observe(self.loaderStackViewHidden.observer)
    self.vm.outputs.loaderText.observe(self.loaderText.observer)
    self.vm.outputs.navBarTitleViewHidden.observe(self.navBarTitleViewHidden.observer)
    self.vm.outputs.navBarLiveDotImageViewHidden.observe(self.navBarLiveDotImageViewHidden.observer)
    self.vm.outputs.numberWatchingBadgeViewHidden.observe(self.numberWatchingBadgeViewHidden.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrlString.observer)
    self.vm.outputs.videoViewControllerHidden.observe(self.videoViewControllerHidden.observer)
    self.vm.outputs.titleViewText.observe(self.titleViewText.observer)
  }

  func testAvailableForText() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.startDate .~ MockDate().date
      |> LiveStreamEvent.lens.id .~ liveStream.id

    self.availableForText.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )

    self.availableForText.assertValue("Available to watch for 2 more days")
  }

  func testCreatorIntroText_Live() {
    let liveStream = Project.LiveStream.template
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    self.creatorIntroText.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.creatorIntroText.assertValues(["<b>Creator Name</b> is live now"])
  }

  func testCreatorIntroText_Replay() {
    let liveStream = Project.LiveStream.template
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream
    |> LiveStreamEvent.lens.stream.liveNow .~ false

    self.creatorIntroText.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.creatorIntroText.assertValues(["<b>Creator Name</b> was live right now"])
  }

  func testCreateLiveStreamViewController() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.createAndConfigureLiveStreamViewController.lastValue == (project, nil, event))
  }

  func testDismiss() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testShowErrorAlert() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .sessionInterrupted), startTime: 0))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .failedToConnect), startTime: 0))

    self.showErrorAlert.assertValues([
      "The live stream was interrupted",
      "The live stream failed to connect"
    ])
  }

  func testLabelVisibilities_Live() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    self.navBarLiveDotImageViewHidden.assertValueCount(0)
    self.createAndConfigureLiveStreamViewController.assertValueCount(0)
    self.numberWatchingBadgeViewHidden.assertValueCount(0)
    self.availableForLabelHidden.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.navBarLiveDotImageViewHidden.assertValues([true, false])
    self.creatorAvatarLiveDotImageViewHidden.assertValues([true, false])
    self.numberWatchingBadgeViewHidden.assertValues([true, false])
    self.availableForLabelHidden.assertValues([true])
  }

  func testLabelVisibilities_Replay() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ false

    self.navBarLiveDotImageViewHidden.assertValueCount(0)
    self.createAndConfigureLiveStreamViewController.assertValueCount(0)
    self.numberWatchingBadgeViewHidden.assertValueCount(0)
    self.availableForLabelHidden.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.navBarLiveDotImageViewHidden.assertValues([true])
    self.creatorAvatarLiveDotImageViewHidden.assertValues([true])
    self.numberWatchingBadgeViewHidden.assertValues([true])
    self.availableForLabelHidden.assertValues([true, false])
  }

  func testNavBarTitleViewHidden_LiveState() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.navBarTitleViewHidden.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.navBarTitleViewHidden.assertValues([true])

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)

    self.navBarTitleViewHidden.assertValues([true])

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .playing, startTime: 123)
    )

    self.navBarTitleViewHidden.assertValues([true, false])
  }

  func testNavBarTitleViewHidden_ReplayState() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.navBarTitleViewHidden.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.navBarTitleViewHidden.assertValues([true])

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)

    self.navBarTitleViewHidden.assertValues([true])

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123)
    )

    self.navBarTitleViewHidden.assertValues([true, false])
  }

  func testLoaderStackViewHidden() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.loaderStackViewHidden.assertValueCount(0)

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123)
    )
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123)
    )

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123)
    )

    self.loaderStackViewHidden.assertValues([false, true])

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .greenRoom
    )

    self.loaderStackViewHidden.assertValues([false, true])
  }

  func testLoaderText() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

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
    let liveStream = Project.LiveStream.template
    let project = Project.template

    self.projectImageUrlString.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, liveStream: liveStream, event: nil, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrlString.assertValues(["http://www.kickstarter.com/full.jpg"])
  }

  func testShowVideoView() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123))

    self.videoViewControllerHidden.assertValues([
      true,
      true,
      false,
      true,
      false
    ])
  }

  func testTitleViewText() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

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

  func testTrackViewedLiveStream() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
  }

  func testTrackLiveStreamOrientationChanged() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.deviceOrientationDidChange(orientation: .landscapeLeft)

    XCTAssertEqual(["Viewed Live Stream", "Changed Live Stream Orientation"], self.trackingClient.events)
    XCTAssertEqual([nil, "live_stream_live"],
                   self.trackingClient.properties(forKey: "context", as: String.self))
    XCTAssertEqual(["project_page", nil],
                   self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, "landscape"], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    XCTAssertEqual(["Viewed Live Stream", "Changed Live Stream Orientation",
                    "Changed Live Stream Orientation"], self.trackingClient.events)
    XCTAssertEqual([nil, "live_stream_live", "live_stream_live"],
                   self.trackingClient.properties(forKey: "context", as: String.self))
    XCTAssertEqual(["project_page", nil, nil],
                   self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, "landscape", "portrait"],
                   self.trackingClient.properties(forKey: "type", as: String.self))
  }

  func testTrackWatchedLiveStream() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
    let event = LiveStreamEvent.template

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 0))

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "duration", as: String.self))

    self.scheduler.advance(by: .seconds(45))

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "duration", as: String.self))

    self.scheduler.advance(by: .seconds(15))

    XCTAssertEqual(["Viewed Live Stream", "Watched Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page"], self.trackingClient.properties(
      forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, 1], self.trackingClient.properties(forKey: "duration", as: Int.self))

    self.scheduler.advance(by: .seconds(60))

    XCTAssertEqual(["Viewed Live Stream", "Watched Live Stream", "Watched Live Stream"],
                   self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page", "project_page"], self.trackingClient.properties(
      forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, 1, 2], self.trackingClient.properties(forKey: "duration", as: Int.self))
  }

  func testTrackWatchedLiveReplay() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
    let project = Project.template
    let event = LiveStreamEvent.template

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .replay(playbackState: .playing, duration: 0))

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "duration", as: String.self))

    self.scheduler.advance(by: .seconds(45))

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "duration", as: String.self))

    self.scheduler.advance(by: .seconds(15))

    XCTAssertEqual(["Viewed Live Stream", "Watched Live Stream Replay"], self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page"], self.trackingClient.properties(
      forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, 1], self.trackingClient.properties(forKey: "duration", as: Int.self))

    self.scheduler.advance(by: .seconds(60))

    XCTAssertEqual(["Viewed Live Stream", "Watched Live Stream Replay", "Watched Live Stream Replay"],
                   self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page", "project_page"], self.trackingClient.properties(
      forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil, 1, 2], self.trackingClient.properties(forKey: "duration", as: Int.self))
  }

  func test_MakeSureSingleLiveStreamControllerIsCreated() {
    let liveStream = Project.LiveStream.template
    let event = LiveStreamEvent.template
    let project = Project.template

    self.vm.inputs.configureWith(
      project: project, liveStream: liveStream, event: event, refTag: .projectPage
    )
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .replay(playbackState: .loading, duration: 0))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.retrievedLiveStreamEvent(event: event)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .replay(playbackState: .loading, duration: 0))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)

    self.createAndConfigureLiveStreamViewController.assertValueCount(1)
  }
}

private func == (tuple1: (Project, Int?, LiveStreamEvent)?,
                 tuple2: (Project, Int?, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
