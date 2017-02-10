import Prelude
import ReactiveSwift
import XCTest
@testable import KsApi
@testable import Library
@testable import LiveStream
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result

final class LiveStreamDiscoveryViewModelTests: TestCase {
  let vm: LiveStreamDiscoveryViewModelType = LiveStreamDiscoveryViewModel()

  private let goToLiveStreamContainerProject = TestObserver<Project, NoError>()
  private let goToLiveStreamContainerLiveStreamEvent = TestObserver<LiveStreamEvent, NoError>()
  private let goToLiveStreamCountdownProject = TestObserver<Project, NoError>()
  private let goToLiveStreamCountdownLiveStreamEvent = TestObserver<LiveStreamEvent, NoError>()
  private let loadDataSource = TestObserver<[LiveStreamEvent], NoError>()
  private let showAlert = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToLiveStreamContainer.map(first).observe(self.goToLiveStreamContainerProject.observer)
    self.vm.outputs.goToLiveStreamContainer.map(second)
      .observe(self.goToLiveStreamContainerLiveStreamEvent.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(first).observe(self.goToLiveStreamCountdownProject.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(second)
      .observe(self.goToLiveStreamCountdownLiveStreamEvent.observer)
    self.vm.outputs.loadDataSource.observe(self.loadDataSource.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
  }

  func testGotoLiveStreamContainer_TappedCurrentlyLiveStream() {
    let project = Project.template
      |> Project.lens.id .~ 42
    let liveStreamsEnvelope = .template
      |> LiveStreamEventsEnvelope.lens.liveStreamEvents .~ (
        (0...4).map { .template |> LiveStreamEvent.lens.id .~ $0 }
    )
    let tappedLiveStream = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    let apiService = MockService(fetchProjectResponse: project)
    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: .success(liveStreamsEnvelope))
    withEnvironment(apiService: apiService, liveStreamService: liveStreamService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.isActive(true)

      self.vm.inputs.tapped(liveStreamEvent: tappedLiveStream)

      self.goToLiveStreamContainerProject.assertValues([project])
      self.goToLiveStreamContainerLiveStreamEvent.assertValues([tappedLiveStream])
      self.goToLiveStreamCountdownProject.assertValues([])
      self.goToLiveStreamCountdownLiveStreamEvent.assertValues([])
    }
  }

  func testGotoLiveStreamContainer_UpcomingLiveStream() {
    let project = Project.template
      |> Project.lens.id .~ 42
    let liveStreamsEnvelope = .template
      |> LiveStreamEventsEnvelope.lens.liveStreamEvents .~ (
        (0...4).map { .template |> LiveStreamEvent.lens.id .~ $0 }
    )
    let tappedLiveStream = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date

    let apiService = MockService(fetchProjectResponse: project)
    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: .success(liveStreamsEnvelope))
    withEnvironment(apiService: apiService, liveStreamService: liveStreamService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.isActive(true)

      self.vm.inputs.tapped(liveStreamEvent: tappedLiveStream)

      self.goToLiveStreamContainerProject.assertValues([])
      self.goToLiveStreamContainerLiveStreamEvent.assertValues([])
      self.goToLiveStreamCountdownProject.assertValues([project])
      self.goToLiveStreamCountdownLiveStreamEvent.assertValues([tappedLiveStream])
    }
  }

  func testGotoLiveStreamContainer_ReplayLiveStream() {
    let project = Project.template
      |> Project.lens.id .~ 42
    let liveStreamsEnvelope = .template
      |> LiveStreamEventsEnvelope.lens.liveStreamEvents .~ (
        (0...4).map { .template |> LiveStreamEvent.lens.id .~ $0 }
    )
    let tappedLiveStream = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true

    let apiService = MockService(fetchProjectResponse: project)
    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: .success(liveStreamsEnvelope))
    withEnvironment(apiService: apiService, liveStreamService: liveStreamService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.isActive(true)

      self.vm.inputs.tapped(liveStreamEvent: tappedLiveStream)

      self.goToLiveStreamContainerProject.assertValues([project])
      self.goToLiveStreamContainerLiveStreamEvent.assertValues([tappedLiveStream])
      self.goToLiveStreamCountdownProject.assertValues([])
      self.goToLiveStreamCountdownLiveStreamEvent.assertValues([])
    }
  }

  func testLoadDataSource() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.isActive(true)

    self.loadDataSource.assertValueCount(1)

    self.vm.inputs.isActive(true)

    self.loadDataSource.assertValueCount(2)
  }

  func testShowAlert() {
    let apiService = MockService(fetchProjectError: ErrorEnvelope.couldNotParseJSON)

    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.isActive(true)

      self.vm.inputs.tapped(liveStreamEvent: .template)

      self.goToLiveStreamContainerProject.assertValues([])
      self.goToLiveStreamContainerLiveStreamEvent.assertValues([])
      self.goToLiveStreamCountdownProject.assertValues([])
      self.goToLiveStreamCountdownLiveStreamEvent.assertValues([])
      self.showAlert.assertValues(["Couldn‘t open live stream. Try again later."])
    }
  }

  func testLoadDataSource_Refreshes() {
    let project = Project.template
      |> Project.lens.id .~ 42
    let liveStreamsEnvelope = .template
      |> LiveStreamEventsEnvelope.lens.liveStreamEvents .~ (
        (0...4).map { .template |> LiveStreamEvent.lens.id .~ $0 }
    )

    let apiService = MockService(fetchProjectResponse: project)
    let liveStreamService = MockLiveStreamService(fetchEventsForProjectResult: .success(liveStreamsEnvelope))
    withEnvironment(apiService: apiService, liveStreamService: liveStreamService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.isActive(true)

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(1)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(false))

      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(2)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(false))

      self.vm.inputs.isActive(false)

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(3)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(true))

      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(3)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(true))

      self.vm.inputs.isActive(true)

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(4)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(false))

      self.vm.inputs.appWillEnterForeground()

      self.scheduler.advance()

      self.loadDataSource.assertValueCount(5)
      XCTAssertTrue(self.loadDataSource.lastValue?.isEmpty == .some(false))
    }
  }

  func testKoalaTracking() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.isActive(true)

    XCTAssertEqual(["Viewed Live Stream Discovery"], self.trackingClient.events)

    self.vm.inputs.isActive(false)

    XCTAssertEqual(["Viewed Live Stream Discovery"], self.trackingClient.events)

    self.vm.inputs.isActive(false)

    XCTAssertEqual(["Viewed Live Stream Discovery", "Viewed Live Stream Discovery"],
                   self.trackingClient.events)
  }
}
