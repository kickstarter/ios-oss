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

  private let configureLiveStreamViewControllerProject =
    TestObserver<Project, NoError>()
  private let configureLiveStreamViewControllerLiveStreamEvent =
    TestObserver<LiveStreamEvent, NoError>()
  private let configureNavBarTitleView =
    TestObserver<LiveStreamEvent, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let displayModalOverlay = TestObserver<(), NoError>()
  private let loaderActivityIndicatorAnimating = TestObserver<Bool, NoError>()
  private let loaderStackViewHidden = TestObserver<Bool, NoError>()
  private let loaderText = TestObserver<String, NoError>()
  private let navBarTitleViewHidden = TestObserver<Bool, NoError>()
  private let projectImageUrlString = TestObserver<String?, NoError>()
  private let removeModalOverlay = TestObserver<(), NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let videoViewControllerHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureLiveStreamViewController.map(first).observe(
      self.configureLiveStreamViewControllerProject.observer)
    self.vm.outputs.configureLiveStreamViewController.map(second).observe(
      self.configureLiveStreamViewControllerLiveStreamEvent.observer)
    self.vm.outputs.configureNavBarTitleView.observe(
      self.configureNavBarTitleView.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.displayModalOverlayView.observe(self.displayModalOverlay.observer)
    self.vm.outputs.loaderActivityIndicatorAnimating.observe(self.loaderActivityIndicatorAnimating.observer)
    self.vm.outputs.loaderStackViewHidden.observe(self.loaderStackViewHidden.observer)
    self.vm.outputs.loaderText.observe(self.loaderText.observer)
    self.vm.outputs.navBarTitleViewHidden.observe(self.navBarTitleViewHidden.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrlString.observer)
    self.vm.outputs.removeModalOverlayView.observe(self.removeModalOverlay.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.videoViewControllerHidden.observe(self.videoViewControllerHidden.observer)
  }

  func testConfigureLiveStreamViewController_CurrentlyLive() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.configureLiveStreamViewControllerProject.assertValueCount(0)
    self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])
    }
  }

  func testConfigureLiveStreamViewController_LiveAfterFetch() {
    let project = Project.template
    let nonLiveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
    let liveStreamEvent = nonLiveStreamEvent
      |> LiveStreamEvent.lens.liveNow .~ true

    withEnvironment(liveStreamService: MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: nonLiveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.configureLiveStreamViewControllerProject.assertValueCount(0)
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

      self.scheduler.advance()

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([nonLiveStreamEvent])
    }
  }

  func testConfigureLiveStreamViewController_LiveAfterFetchingForSomeTime() {
    let project = Project.template
    let nonLiveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
    let liveStreamEvent = nonLiveStreamEvent
      |> LiveStreamEvent.lens.liveNow .~ true

    withEnvironment(liveStreamService: MockLiveStreamService(fetchEventResult: Result(nonLiveStreamEvent))) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.configureLiveStreamViewControllerProject.assertValueCount(0)
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.configureLiveStreamViewControllerProject.assertValueCount(0)
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)
    }

    withEnvironment(liveStreamService: MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))) {
      self.scheduler.advance(by: .seconds(5))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([nonLiveStreamEvent])

      self.scheduler.advance(by: .seconds(5))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([nonLiveStreamEvent])
    }
  }

  func testDismiss() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testShowErrorAlert() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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

  func testShowErrorAlert_FailedToFetchLiveStreamEvent() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(error: .genericFailure))

    self.showErrorAlert.assertValueCount(0)
    self.loaderActivityIndicatorAnimating.assertValueCount(0)

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.showErrorAlert.assertValues(["The live stream failed to connect"])
      self.loaderActivityIndicatorAnimating.assertValues([true, false])
    }
  }

  func testLoaderStackViewHidden() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.loaderStackViewHidden.assertValueCount(0)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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

  func testLoaderIndicatorViewHidden() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.loaderActivityIndicatorAnimating.assertValueCount(0)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.loaderActivityIndicatorAnimating.assertValues([true])

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .nonStarter)

    self.loaderActivityIndicatorAnimating.assertValues([true, false])
  }

  func testProjectImageUrl() {
    self.vm.inputs.configureWith(project: .template,
                                 liveStreamEvent: .template,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrlString.assertValues([nil, "http://www.kickstarter.com/full.jpg"])
  }

  func testShowVideoView() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
      self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(
        playbackState: .playing, startTime: 123))
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
  }

  func testTrackViewedLiveStream() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
  }

  func testTrackClosedLiveStream() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.scheduler.advance(by: .seconds(50))

    self.vm.inputs.closeButtonTapped()

    XCTAssertEqual(["Viewed Live Stream", "Closed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page"], self.trackingClient.properties(forKey: "ref_tag",
                                                                                    as: String.self))
    XCTAssertEqual([nil, "live_stream_live"], self.trackingClient.properties(forKey: "type",
                                                                               as: String.self))
    XCTAssertEqual([nil, 50], self.trackingClient.properties(forKey: "duration", as: Double.self))
  }

  func testTrackClosedLiveStreamReplay() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "type", as: String.self))
    XCTAssertEqual([nil], self.trackingClient.properties(forKey: "duration", as: Double.self))

    self.scheduler.advance(by: .seconds(50))

    self.vm.inputs.closeButtonTapped()

    XCTAssertEqual(["Viewed Live Stream", "Closed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page"], self.trackingClient.properties(forKey: "ref_tag",
                                                                                    as: String.self))
    XCTAssertEqual([nil, "live_stream_replay"], self.trackingClient.properties(forKey: "type",
                                                                               as: String.self))
    XCTAssertEqual([nil, 50], self.trackingClient.properties(forKey: "duration", as: Double.self))
  }

  func testTrackLiveStreamOrientationChanged() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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
    XCTAssertEqual([nil, 1, 1], self.trackingClient.properties(forKey: "duration", as: Int.self))
  }

  func testTrackWatchedLiveReplay() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
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
    XCTAssertEqual([nil, 1, 1], self.trackingClient.properties(forKey: "duration", as: Int.self))
  }

  func testMakeSureSingleLiveStreamControllerIsCreated() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
    let project = Project.template

    self.configureLiveStreamViewControllerProject.assertValueCount(0)
    self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])

      self.vm.inputs.liveStreamViewControllerStateChanged(state: .replay(
        playbackState: .loading, duration: 0))
      self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)

      self.vm.inputs.liveStreamViewControllerStateChanged(state: .replay(
        playbackState: .loading, duration: 0))
      self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])
    }
  }

  func testCreateLiveStreamViewController_Live() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
    let project = Project.template

    self.configureLiveStreamViewControllerProject.assertValueCount(0)
    self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])
    }
  }

  func testCreateLiveStreamViewController_Replay() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60).date
    let project = Project.template

    self.configureLiveStreamViewControllerProject.assertValueCount(0)
    self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])
    }
  }

  func testCreateLiveStreamViewController_DefinitelyNoReplay_DisplayError() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ false
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60).date
    let project = Project.template

    self.configureLiveStreamViewControllerProject.assertValueCount(0)
    self.configureLiveStreamViewControllerLiveStreamEvent.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    self.loaderText.assertValueCount(0)

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderText.assertValues(["Loading"])

      self.scheduler.advance(by: .seconds(3))

      self.configureLiveStreamViewControllerProject.assertValues([project])
      self.configureLiveStreamViewControllerLiveStreamEvent.assertValues([liveStreamEvent])

      self.vm.inputs.liveStreamViewControllerStateChanged(state: .nonStarter)

      self.loaderText.assertValues(["Loading", "No replay is available for this live stream."])
    }
  }

  func testConfigureNavBarTitleView() {
    let liveStreamEvent = LiveStreamEvent.template
    let project = Project.template

    self.configureNavBarTitleView.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance(by: .seconds(3))

      self.configureNavBarTitleView.assertValues([liveStreamEvent])
    }
  }

  func testNavBarTitleViewHidden() {
    let liveStreamEvent = LiveStreamEvent.template
    let project = Project.template

    self.navBarTitleViewHidden.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.navBarTitleViewHidden.assertValues([true])

      self.scheduler.advance(by: .seconds(3))

      self.navBarTitleViewHidden.assertValues([true, false])
    }
  }

  func testDisplayRemoveModalOverlay() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.displayModalOverlay.assertValueCount(0)
    self.removeModalOverlay.assertValueCount(0)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.willPresentMoreMenuViewController()

    self.displayModalOverlay.assertValueCount(1)

    self.vm.inputs.willDismissMoreMenuViewController()

    self.removeModalOverlay.assertValueCount(1)
  }
}
