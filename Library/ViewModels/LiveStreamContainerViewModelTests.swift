// swiftlint:disable file_length
// swiftlint:disable type_body_length
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamContainerViewModelTests: TestCase {
  private var vm: LiveStreamContainerViewModelType!

  private let configurePageViewControllerProject = TestObserver<Project, NoError>()
  private let configurePageViewControllerLiveStreamEvent = TestObserver<LiveStreamEvent, NoError>()
  private let configurePageViewControllerRefTag = TestObserver<RefTag, NoError>()
  private let configurePageViewControllerPresentedFromProject = TestObserver<Bool, NoError>()
  private let configureNavBarTitleView = TestObserver<LiveStreamEvent, NoError>()
  private let createVideoViewController = TestObserver<LiveStreamType, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let loaderActivityIndicatorAnimating = TestObserver<Bool, NoError>()
  private let loaderStackViewHidden = TestObserver<Bool, NoError>()
  private let loaderText = TestObserver<String, NoError>()
  private let navBarTitleViewHidden = TestObserver<Bool, NoError>()
  private let numberOfPeopleWatching = TestObserver<Int, NoError>()
  private let projectImageUrlString = TestObserver<String?, NoError>()
  private let removeVideoViewController = TestObserver<(), NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let videoViewControllerHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm = LiveStreamContainerViewModel()

    self.vm.outputs.configurePageViewController.map { $0.0 }
      .observe(self.configurePageViewControllerProject.observer)
    self.vm.outputs.configurePageViewController.map { $0.1 }
      .observe(self.configurePageViewControllerLiveStreamEvent.observer)
    self.vm.outputs.configurePageViewController.map { $0.2 }
      .observe(self.configurePageViewControllerRefTag.observer)
    self.vm.outputs.configurePageViewController.map { $0.3 }
      .observe(self.configurePageViewControllerPresentedFromProject.observer)
    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.configureNavBarTitleView.observe(self.configureNavBarTitleView.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.loaderActivityIndicatorAnimating.observe(self.loaderActivityIndicatorAnimating.observer)
    self.vm.outputs.loaderStackViewHidden.observe(self.loaderStackViewHidden.observer)
    self.vm.outputs.loaderText.observe(self.loaderText.observer)
    self.vm.outputs.navBarTitleViewHidden.observe(self.navBarTitleViewHidden.observer)
    self.vm.outputs.numberOfPeopleWatching.observe(self.numberOfPeopleWatching.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrlString.observer)
    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.videoViewControllerHidden.observe(self.videoViewControllerHidden.observer)
  }

  func testConfigurePageViewController() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template

    self.configurePageViewControllerProject.assertValueCount(0)
    self.configurePageViewControllerLiveStreamEvent.assertValueCount(0)
    self.configurePageViewControllerRefTag.assertValueCount(0)
    self.configurePageViewControllerPresentedFromProject.assertValueCount(0)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.configurePageViewControllerProject.assertValues([project])
    self.configurePageViewControllerLiveStreamEvent.assertValues([liveStreamEvent])
    self.configurePageViewControllerRefTag.assertValues([.projectPage])
    self.configurePageViewControllerPresentedFromProject.assertValues([true])
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

    self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .sessionInterrupted))
    self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .failedToConnect))

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

  func testLoaderStackViewHidden_Live() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.loaderStackViewHidden.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderStackViewHidden.assertValues([false])

      self.scheduler.advance()

      self.loaderStackViewHidden.assertValues([false])

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

      self.loaderStackViewHidden.assertValues([false, true])
    }
  }

  func testLoaderText_Live() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.loaderText.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderText.assertValues(["Loading"])

      self.scheduler.advance()

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.loaderText.assertValues(["Loading", "Joining the live stream"])
    }
  }

  func testLoaderText_LiveFromCountdown() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.loaderText.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .liveStreamCountdown,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderText.assertValues(["Loading"])

      self.scheduler.advance()

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.loaderText.assertValues(["Loading", "The live stream will start soon"])
    }
  }

  func testLoaderText_Replay() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.loaderText.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderText.assertValues(["Loading"])

      self.scheduler.advance()

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.loaderText.assertValues(["Loading", "The replay will start soon"])
    }
  }

  func testLoaderText_NonStarter() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.loaderText.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderText.assertValues(["Loading"])

      self.scheduler.advance()

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.loaderText.assertValues(["Loading", "No replay is available for this live stream."])
    }
  }

  func testLoaderActivityIndicatorAnimating_NonStarter() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.loaderActivityIndicatorAnimating.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderActivityIndicatorAnimating.assertValues([true])

      self.scheduler.advance()

      self.loaderActivityIndicatorAnimating.assertValues([true, false])
    }
  }

  func testLoaderActivityIndicatorAnimating_Error() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.loaderActivityIndicatorAnimating.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.loaderActivityIndicatorAnimating.assertValues([true])

      self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .failedToConnect))

      self.loaderActivityIndicatorAnimating.assertValues([true, false])
    }
  }

  func testProjectImageUrl() {
    self.vm.inputs.configureWith(project: .template,
                                 liveStreamEvent: .template,
                                 refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrlString.assertValues([nil, "http://www.kickstarter.com/full.jpg"])
  }

  func testNumberOfPeopleWatching_NonScaleEvent() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20
      |> LiveStreamEvent.lens.isScale .~ false

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.numberOfPeopleWatching.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.numberOfPeopleWatching.assertValues([10])
    }
  }

  func testNumberOfPeopleWatching_ScaleEvent() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20
      |> LiveStreamEvent.lens.isScale .~ true

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      scaleNumberOfPeopleWatchingResult: Result([10])
    )

    self.numberOfPeopleWatching.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.numberOfPeopleWatching.assertValues([10])
    }
  }

  func testNumberOfPeopleWatching_ZeroOnErrors() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result(error: .genericFailure)
    )

    self.numberOfPeopleWatching.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.numberOfPeopleWatching.assertValues([0])
    }
  }

  func testShowVideoView_Live() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.videoViewControllerHidden.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.videoViewControllerHidden.assertValueCount(0)

      self.scheduler.advance()

      self.videoViewControllerHidden.assertValueCount(0)

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.videoViewControllerHidden.assertValues([true])

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

      self.videoViewControllerHidden.assertValues([true, false])
    }
  }

  func testShowVideoView_Replay() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.videoViewControllerHidden.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.videoViewControllerHidden.assertValueCount(0)

      self.scheduler.advance()

      self.videoViewControllerHidden.assertValueCount(0)

      self.vm.inputs.videoPlaybackStateChanged(state: .loading)

      self.videoViewControllerHidden.assertValues([true])

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

      self.videoViewControllerHidden.assertValues([true, false])
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

    self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

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

    self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

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

  func testCreateVideoViewController_LiveAfterFetchingForSomeTime() {
    let project = Project.template
    let nonLiveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
    let liveStreamEvent = nonLiveStreamEvent
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceNonLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false]),
      fetchEventResult: Result(nonLiveStreamEvent)
    )

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    guard let openTokStreamType = liveStreamEvent.openTok.flatMap({ openTok -> LiveStreamType in
      LiveStreamType.openTok(
        sessionConfig: .init(
          apiKey: openTok.appId,
          sessionId: openTok.sessionId,
          token: openTok.token)
      )
    }) else {
      XCTFail("OpenTok values should exist")
      return
    }

    withEnvironment(liveStreamService: liveStreamServiceNonLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValueCount(0)
    }

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValues([openTokStreamType])
    }
  }

  func testCreateVideoViewController_Live_UnderMaxOpenTokViewers() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    guard let openTokStreamType = liveStreamEvent.openTok.flatMap({ openTok -> LiveStreamType in
      LiveStreamType.openTok(
        sessionConfig: .init(
          apiKey: openTok.appId,
          sessionId: openTok.sessionId,
          token: openTok.token)
      )
    }) else {
      XCTFail("OpenTok values should exist")
      return
    }

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValues([openTokStreamType])
    }
  }

  func testCreateVideoViewController_Live_OverMaxOpenTokViewers() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([30])
    )

    guard let replayUrl = liveStreamEvent.hlsUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValues([hlsStreamType])
    }
  }

  func testCreateVideoViewController_Live_NumberOfPeopleTimesOut() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamEventIncomplete = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResultNever: true,
      scaleNumberOfPeopleWatchingResultNever: true
    )

    guard let replayUrl = liveStreamEvent.hlsUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEventIncomplete,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(10))

      self.createVideoViewController.assertValues([hlsStreamType])
    }
  }

  func testCreateVideoViewController_Replay() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    guard let replayUrl = liveStreamEvent.replayUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    self.createVideoViewController.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance()

      self.createVideoViewController.assertValues([hlsStreamType])
    }
  }

  func testCreateVideoViewController_NonStarter_DisplayError() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    self.loaderText.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance()

      self.createVideoViewController.assertValueCount(0)

      self.loaderText.assertValues(["Loading", "No replay is available for this live stream."])
    }
  }

  func testCreateVideoViewController_Live_HlsUrlChanges() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      hlsUrlResult: Result(["http://www.url2.com"]),
      numberOfPeopleWatchingResult: Result([30])
    )

    guard let replayUrl = liveStreamEvent.hlsUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)
    let changedHlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: "http://www.url2.com")

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.createVideoViewController.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.createVideoViewController.assertValues([hlsStreamType, changedHlsStreamType])
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

  func testGreenRoomErrorBeforeCreatingVideoViewController() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result(error: .genericFailure),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    self.showErrorAlert.assertValueCount(0)

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.showErrorAlert.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.showErrorAlert.assertValueCount(1)
      self.createVideoViewController.assertValueCount(0)
    }
  }

  func testVideoEnabledDisabled() {
    self.loaderText.assertValueCount(0)
    self.loaderStackViewHidden.assertValueCount(0)
    self.videoViewControllerHidden.assertValueCount(0)

    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 20

    let liveStreamServiceLiveEvent = MockLiveStreamService(
      greenRoomOffStatusResult: Result([true]),
      fetchEventResult: Result(liveStreamEvent),
      numberOfPeopleWatchingResult: Result([10])
    )

    withEnvironment(liveStreamService: liveStreamServiceLiveEvent) {
      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: .projectPage,
                                   presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.showErrorAlert.assertValueCount(0)

      self.scheduler.advance(by: .seconds(5))

      self.loaderText.assertValues(["Loading"])
      self.loaderStackViewHidden.assertValues([false])
      self.videoViewControllerHidden.assertValueCount(0)

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

      self.loaderText.assertValues(["Loading", "Joining the live stream"])
      self.loaderStackViewHidden.assertValues([false, true])
      self.videoViewControllerHidden.assertValues([false])

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: false))

      self.loaderText.assertValues([
        "Loading",
        "Joining the live stream",
        "The live stream will resume when the connection improves"])

      self.loaderStackViewHidden.assertValues([false, true, false])
      self.videoViewControllerHidden.assertValues([false, true])

      self.vm.inputs.videoPlaybackStateChanged(state: .playing(videoEnabled: true))

      self.loaderText.assertValues([
        "Loading",
        "Joining the live stream",
        "The live stream will resume when the connection improves",
        "Joining the live stream"])

      self.loaderStackViewHidden.assertValues([false, true, false, true])
      self.videoViewControllerHidden.assertValues([false, true, false])
    }
  }
}
