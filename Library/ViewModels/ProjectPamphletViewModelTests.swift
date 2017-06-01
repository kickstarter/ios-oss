// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import LiveStream
@testable import ReactiveExtensions_TestHelpers

final class ProjectPamphletViewModelTests: TestCase {
  fileprivate var vm: ProjectPamphletViewModelType!

  fileprivate let configureChildViewControllersWithProject = TestObserver<Project, NoError>()
  fileprivate let configureChildViewControllersWithLiveStreamEvents =
    TestObserver<[LiveStreamEvent], NoError>()
  fileprivate let configureChildViewControllersWithRefTag = TestObserver<RefTag?, NoError>()
  fileprivate let setNavigationBarHidden = TestObserver<Bool, NoError>()
  fileprivate let setNavigationBarAnimated = TestObserver<Bool, NoError>()
  fileprivate let setNeedsStatusBarAppearanceUpdate = TestObserver<(), NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm = ProjectPamphletViewModel()

    self.vm.outputs.configureChildViewControllersWithProjectAndLiveStreams.map(first)
      .observe(self.configureChildViewControllersWithProject.observer)
    self.vm.outputs.configureChildViewControllersWithProjectAndLiveStreams.map(second)
      .observe(self.configureChildViewControllersWithLiveStreamEvents.observer)
    self.vm.outputs.configureChildViewControllersWithProjectAndLiveStreams.map(third)
      .observe(self.configureChildViewControllersWithRefTag.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(first)
      .observe(self.setNavigationBarHidden.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(second)
      .observe(self.setNavigationBarAnimated.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithProject() {
    let project = Project.template
    let refTag = RefTag.category
    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: refTag)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([[]])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([[], [.template]])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag, refTag])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([[], [.template], [.template]])
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithParam() {
    let project = .template |> Project.lens.id .~ 42

    self.vm.inputs.configureWith(projectOrParam: .right(.id(project.id)), refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([])
    self.configureChildViewControllersWithRefTag.assertValues([])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([nil])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([[.template]])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([nil, nil])
    self.configureChildViewControllersWithLiveStreamEvents.assertValues([[.template], [.template]])
  }

  func testStatusBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)
    XCTAssertFalse(self.vm.outputs.prefersStatusBarHidden)

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.prefersStatusBarHidden)
  }

  func testNavigationBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true])
    self.setNavigationBarAnimated.assertValues([false, true])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true, true])
    self.setNavigationBarAnimated.assertValues([false, true, false])
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(["Project Page", "Viewed Project Page"],
                   self.trackingClient.events, "A project page koala event is tracked.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
                   "The ref tag is tracked in the koala event.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
                   "The referral credit is tracked in the koala event.")
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie is set")
    XCTAssertEqual("ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
                   "A referral cookie is set for the project.")
    XCTAssertEqual("category?",
                   (self.cookieStorage.cookies?.last?.value.characters.prefix(9)).map(String.init),
                   "A referral cookie is set for the category ref tag.")

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(["Project Page", "Viewed Project Page", "Project Page", "Viewed Project Page"],
                   self.trackingClient.events, "A project page koala event is tracked.")
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag, RefTag.recommended.stringTag,
        RefTag.recommended.stringTag],
      self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag, RefTag.category.stringTag,
        RefTag.category.stringTag],
      self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie has been set.")
  }

  func testTracksRefTag_WithBadData() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(["Project Page", "Viewed Project Page"],
                   self.trackingClient.events, "A project page koala event is tracked.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
                   "The ref tag is tracked in the koala event.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
                   "The referral credit is tracked in the koala event.")
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie is set")
    XCTAssertEqual("ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
                   "A referral cookie is set for the project.")
    XCTAssertEqual("category?",
                   (self.cookieStorage.cookies?.last?.value.characters.prefix(9)).map(String.init),
                   "A referral cookie is set for the category ref tag.")

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(["Project Page", "Viewed Project Page", "Project Page", "Viewed Project Page"],
                   self.trackingClient.events, "A project page koala event is tracked.")
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag, RefTag.recommended.stringTag,
        RefTag.recommended.stringTag],
      self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag, RefTag.category.stringTag,
        RefTag.category.stringTag],
      self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie has been set.")
  }

  func testTracking_WaitingForLiveStreams_Timeout() {
    let project = Project.template

    withEnvironment(apiDelayInterval: .seconds(10)) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events, "Nothing tracked because API is taking a long time.")

      self.scheduler.advance(by: .seconds(10))

      XCTAssertEqual([],
                     self.trackingClient.events,
                     "Event tracked once API times out.")
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self),
                     "Live stream type not tracked because we never got data from the API.")

      self.scheduler.advance(by: .seconds(10))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Nothing new tracks after waiting enough time for API to finish.")
      XCTAssertEqual([nil, nil],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self),
                     "Live stream type not tracked because we never got data from the API.")
    }
  }

  func testTracking_WaitingForLiveStreams() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1, liveStreamEvents: [liveStreamEvent])

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(
        projectOrParam: .left(project), refTag: .discovery
      )
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual([], self.trackingClient.events)
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual(["live_stream_live", "live_stream_live"],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStream_Countdown() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60*60).date

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1, liveStreamEvents: [liveStreamEvent])

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual([],
                     self.trackingClient.events,
                     "A project page koala event is tracked.")
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual(["live_stream_countdown", "live_stream_countdown"],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStream_Replay() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60*60).date

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1, liveStreamEvents: [liveStreamEvent])

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual([],
                     self.trackingClient.events, "A project page koala event is tracked.")
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual(["live_stream_replay", "live_stream_replay"],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStream_ConfigWithParam() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60*60).date

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1, liveStreamEvents: [liveStreamEvent])

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(projectOrParam: .right(.id(1)), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual([],
                     self.trackingClient.events,
                     "A project page koala event is tracked.")
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual(["live_stream_replay", "live_stream_replay"],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStream_TypePriority() {
    let project = Project.template
    let liveStreamEventLive = .template
      |> LiveStreamEvent.lens.liveNow .~ true
    let liveStreamEventReplay = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60*60).date

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1,
                                            liveStreamEvents: [liveStreamEventLive, liveStreamEventReplay])

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual([],
                     self.trackingClient.events, "A project page koala event is tracked.")
      XCTAssertEqual([],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual(["live_stream_live", "live_stream_live"],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStreamError_WithProject() {
    let project = Project.template

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(error: .genericFailure))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(
        projectOrParam: .left(project), refTag: .discovery
      )
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual([nil, nil],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTracking_LiveStreamError_WithParams() {
    let project = Project.template

    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: Result(error: .genericFailure))

    withEnvironment(apiDelayInterval: .seconds(3), liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(
        projectOrParam: .right(.id(project.id)), refTag: .discovery
      )
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance(by: .seconds(3))

      XCTAssertEqual(["Project Page", "Viewed Project Page"],
                     self.trackingClient.events,
                     "Waiting more time doesn't track another event.")
      XCTAssertEqual([nil, nil],
                     self.trackingClient.properties(forKey: "live_stream_type", as: String.self))
    }
  }

  func testTrackingDoesNotOccurOnLoad() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    XCTAssertEqual([], self.trackingClient.events)
  }
}
