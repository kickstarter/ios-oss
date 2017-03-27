// swiftlint:disable file_length
// swiftlint:disable type_body_length
import ReactiveSwift
import Result
import XCTest
import Prelude
@testable import LiveStream
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

private struct TestFirebaseAppType: FirebaseAppType {}
private struct TestFirebaseDatabaseReferenceType: FirebaseDatabaseReferenceType {}
private struct TestFirebaseDataSnapshotType: FirebaseDataSnapshotType {
  let key: String
  let value: Any?
}
private struct TestFirebaseServerValueType: FirebaseServerValueType {
  static func timestamp() -> [AnyHashable : Any] {
    return ["timestamp": 12345678]
  }
}

internal final class LiveStreamViewModelTests: XCTestCase {
  private let scheduler = TestScheduler()
  private var vm: LiveStreamViewModelType!

  private let createVideoViewController = TestObserver<LiveStreamType, NoError>()
  private let disableIdleTimer = TestObserver<Bool, NoError>()
  private let greenRoomStatusOff = TestObserver<Bool, LiveApiError>()
  private let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = TestObserver<Int, NoError>()
  private let notifyDelegateLiveStreamViewControllerStateChanged
    = TestObserver<LiveStreamViewControllerState, NoError>()
  private let notifyDelegateLiveStreamApiErrorOccurred = TestObserver<LiveApiError, NoError>()
  private let removeVideoViewController = TestObserver<(), NoError>()

  private func setUp(withLiveStreamService liveStreamService: MockLiveStreamService) {
    self.vm = LiveStreamViewModel(liveStreamService: liveStreamService, scheduler: self.scheduler)

    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.disableIdleTimer.observe(self.disableIdleTimer.observer)
    self.vm.outputs.notifyDelegateLiveStreamApiErrorOccurred.observe(
      self.notifyDelegateLiveStreamApiErrorOccurred.observer)
    self.vm.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged
      .observe(self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observer)
    self.vm.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observe(self.notifyDelegateLiveStreamViewControllerStateChanged.observer)
    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
  }

  override func setUp() {
    super.setUp()
  }

  func testCreateVideoViewController_UnderMaxOpenTokViews() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true]),
      numberOfPeopleWatchingResult: Result([5])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    guard let openTokStreamType = event.openTok.flatMap({ openTok -> LiveStreamType in
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

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValues([openTokStreamType])
  }

  func testCreateVideoViewController_OverMaxOpenTokViews() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true]),
      hlsUrlResult: Result([]),
      numberOfPeopleWatchingResult: Result([15])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateVideoViewController_HlsUrlChanges() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true]),
      hlsUrlResult: Result(["http://www.url2.com", "http://www.url2.com"]),
      numberOfPeopleWatchingResult: Result([15])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.url1.com"

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValues(
      [.hlsStream(hlsStreamUrl: "http://www.url2.com"), hlsStreamType]
    )
  }

  func testCreateVideoViewController_NumberOfPeopleTimesOut() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true]),
      numberOfPeopleWatchingResult: Result([])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.scheduler.advance(by: .seconds(10))

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateVideoViewController_Replay() {
    let mockService = MockLiveStreamService()

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    guard let replayUrl = event.replayUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_NonScaleEvent() {
    let mockService = MockLiveStreamService(
      numberOfPeopleWatchingResult: Result([5, 7]),
      scaleNumberOfPeopleWatchingResult: Result([15, 20])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ false

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([5, 7])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_ScaleEvent() {
    let mockService = MockLiveStreamService(
      numberOfPeopleWatchingResult: Result([5, 7]),
      scaleNumberOfPeopleWatchingResult: Result([15, 20])
    )

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ true

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([15, 20])
  }

  func testCreateVideoViewController_RTMPStreamDefaultsToHLS() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true])
    )

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.isRtmp .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(liveStreamEvent: event)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateFirebaseFailedToInitialize() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result(error: .failedToInitializeFirebase)
    )

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.isRtmp .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(liveStreamEvent: event)

    self.notifyDelegateLiveStreamApiErrorOccurred.assertValues([.failedToInitializeFirebase])
  }

  func testDisableIdleTimer() {
    let mockService = MockLiveStreamService()

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template

    self.disableIdleTimer.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.disableIdleTimer.assertValues([true])

    self.vm.inputs.viewDidDisappear()

    self.disableIdleTimer.assertValues([true, false])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_LifeCycle() {
    let mockService = MockLiveStreamService(
      greenRoomOffStatusResult: Result([false, true])
    )

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.videoPlaybackStateChanged(state: .loading)

    self.vm.inputs.videoPlaybackStateChanged(state: .playing)

    self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .sessionInterrupted))

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.greenRoom, .loading, .live(playbackState: .loading, startTime: 0),
        .live(playbackState: .playing, startTime: 0), .error(error: .sessionInterrupted)
      ]
    )
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_NotLive_NoReplay() {
    let mockService = MockLiveStreamService()

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ false
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -16 * 60)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.nonStarter])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_NotLive_Replay_NoReplayUrl() {
    let mockService = MockLiveStreamService()

    setUp(withLiveStreamService: mockService)

    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.nonStarter])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_ReplayState() {
    let mockService = MockLiveStreamService()

    setUp(withLiveStreamService: mockService)

    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)

    self.vm.inputs.configureWith(liveStreamEvent: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading]
    )

    self.vm.inputs.videoPlaybackStateChanged(state: .loading)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .replay(playbackState: .loading, duration: 0)]
    )

    self.vm.inputs.videoPlaybackStateChanged(state: .playing)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .replay(playbackState: .loading, duration: 0),
        .replay(playbackState: .playing, duration: 0)]
    )

    self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .sessionInterrupted))

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .replay(playbackState: .loading, duration: 0),
        .replay(playbackState: .playing, duration: 0),
        .error(error: .sessionInterrupted),
      ]
    )
  }
}
