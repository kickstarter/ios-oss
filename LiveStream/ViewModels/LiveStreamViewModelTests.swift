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
  private let backgroundQueueScheduler = TestScheduler()
  private let scheduler = TestScheduler()
  private var vm: LiveStreamViewModelType!

  private let chatMessages = TestObserver<[LiveStreamChatMessage], NoError>()
  private let createChatObservers
    = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createPresenceReference = TestObserver<FirebaseRefConfig, NoError>()
  private let createGreenRoomObservers
    = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createHLSObservers = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createNumberOfPeopleWatchingObservers
    = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createScaleNumberOfPeopleWatchingObservers
    = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createVideoViewController = TestObserver<LiveStreamType, NoError>()
  private let disableIdleTimer = TestObserver<Bool, NoError>()
  private let initializeFirebaseEvent = TestObserver<LiveStreamEvent, NoError>()
  private let initializeFirebaseUserId = TestObserver<Int?, NoError>()
  private let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = TestObserver<Int, NoError>()
  private let notifyDelegateLiveStreamViewControllerStateChanged
    = TestObserver<LiveStreamViewControllerState, NoError>()
  private let removeVideoViewController = TestObserver<(), NoError>()
  private let writeChatMessageToFirebaseDbRef = TestObserver<FirebaseDatabaseReferenceType, NoError>()
  private let writeChatMessageToFirebaseRefConfig = TestObserver<FirebaseRefConfig, NoError>()
  private let writeChatMessageToFirebaseMessageData = TestObserver<[AnyHashable:Any], NoError>()

  override func setUp() {
    super.setUp()

    self.vm = LiveStreamViewModel(environment: LiveStreamAppEnvironment(
      backgroundQueueScheduler: self.backgroundQueueScheduler,
      scheduler: self.scheduler
      )
    )

    self.vm.outputs.chatMessages.observe(self.chatMessages.observer)
    self.vm.outputs.createChatObservers.observe(self.createChatObservers.observer)
    self.vm.outputs.createPresenceReference.map(second).observe(self.createPresenceReference.observer)
    self.vm.outputs.createGreenRoomObservers.observe(self.createGreenRoomObservers.observer)
    self.vm.outputs.createHLSObservers.observe(self.createHLSObservers.observer)
    self.vm.outputs.createNumberOfPeopleWatchingObservers
      .observe(self.createNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.createScaleNumberOfPeopleWatchingObservers
      .observe(self.createScaleNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.disableIdleTimer.observe(self.disableIdleTimer.observer)

    self.vm.outputs.initializeFirebase.map(first).observe(self.initializeFirebaseEvent.observer)
    self.vm.outputs.initializeFirebase.map(second).observe(self.initializeFirebaseUserId.observer)

    self.vm.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged
      .observe(self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observer)
    self.vm.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observe(self.notifyDelegateLiveStreamViewControllerStateChanged.observer)
    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
    self.vm.outputs.writeChatMessageToFirebase.map { $0.0 }.observe(self.writeChatMessageToFirebaseDbRef.observer)
    self.vm.outputs.writeChatMessageToFirebase.map { $0.1 }.observe(self.writeChatMessageToFirebaseRefConfig.observer)
    self.vm.outputs.writeChatMessageToFirebase.map { $0.2 }.observe(self.writeChatMessageToFirebaseMessageData.observer)
  }

  func testInitalizeFirebase_LiveEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.initializeFirebaseEvent.assertValues([event])
    self.initializeFirebaseUserId.assertValues([nil])
  }

  func testInitalizeFirebase_ReplayEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.initializeFirebaseEvent.assertValues([])
    self.initializeFirebaseUserId.assertValues([])
  }

  func testCreateVideoViewController_UnderMaxOpenTokViews() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ false

    let dictionary5 = [Int: Int].keyValuePairs(Array(1...5).map { ($0, $0) })
    let dictionary15 = [Int: Int].keyValuePairs(Array(1...15).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

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

    self.createVideoViewController.assertValues([openTokStreamType])

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    self.createVideoViewController.assertValues(
      [openTokStreamType], "Nothing new emitted since we started in OpenTok stream."
    )

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.createVideoViewController.assertValues(
      [openTokStreamType], "Nothing new emitted since we started in OpenTok stream."
    )
    self.removeVideoViewController.assertValueCount(0)
  }

  func testCreateVideoViewController_UnderMaxOpenTokViews_ForScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 5)

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

    self.createVideoViewController.assertValues([openTokStreamType])

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    self.createVideoViewController.assertValues(
      [openTokStreamType], "Nothing new emitted since we started in OpenTok stream."
    )

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 5)

    self.createVideoViewController.assertValues(
      [openTokStreamType], "Nothing new emitted since we started in OpenTok stream."
    )
    self.removeVideoViewController.assertValueCount(0)
  }

  func testCreateVideoViewController_OverMaxOpenTokViews_NonScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ false

    let dictionary5 = [Int: Int].keyValuePairs(Array(1...5).map { ($0, $0) })
    let dictionary15 = [Int: Int].keyValuePairs(Array(1...15).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.createVideoViewController.assertValues(
      [hlsStreamType], "Nothing new emitted since we started in HLS stream."
    )

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    self.createVideoViewController.assertValues(
      [hlsStreamType], "Nothing new emitted since we started in HLS stream."
    )
    self.removeVideoViewController.assertValueCount(0)
  }

  func testCreateVideoViewController_OverMaxOpenTokViews_ForScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ true
    |> LiveStreamEvent.lens.hlsUrl .~ "http://www.mp4"

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 5)

    self.createVideoViewController.assertValues(
      [hlsStreamType], "Nothing new emitted since we started in HLS stream."
    )

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    self.createVideoViewController.assertValues(
      [hlsStreamType], "Nothing new emitted since we started in HLS stream."
    )
    self.removeVideoViewController.assertValueCount(0)
  }

  func testCreateVideoViewController_TogglingGreenRoom() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    let dictionary5 = [Int: Int].keyValuePairs(Array(1...5).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

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

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(1)
  }

  func testCreateVideoViewController_OpenTokOnlyEvent() {
    let event = .template
      |> LiveStreamEvent.lens.hlsUrl .~ nil
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    let dictionary5 = [Int: Int].keyValuePairs(Array(1...5).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

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

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(1)
  }

  func testCreateVideoViewController_HlsOnlyEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    let dictionary15 = [Int: Int].keyValuePairs(Array(1...15).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateVideoViewController_HlsUrlChanges() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    let dictionary15 = [Int: Int].keyValuePairs(Array(1...15).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])

    let newHlsUrl = "http://www.something.com/vid.mp4"
    self.vm.inputs.observedHlsUrlChanged(hlsUrl: newHlsUrl)

    self.createVideoViewController.assertValues([hlsStreamType, .hlsStream(hlsStreamUrl: newHlsUrl)])

    self.vm.inputs.observedHlsUrlChanged(hlsUrl: newHlsUrl)

    self.createVideoViewController.assertValues(
      [hlsStreamType, .hlsStream(hlsStreamUrl: newHlsUrl)], "Does not emit again because url did not change"
    )

    self.removeVideoViewController.assertValueCount(0)
  }

  func testCreateVideoViewController_NumberOfPeopleTimesOut() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.scheduler.advance(by: .seconds(10))

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateVideoViewController_Replay() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    guard let replayUrl = event.replayUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_NonScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ false

    let dictionary5 = [Int: Int].keyValuePairs(Array(1...5).map { ($0, $0) })
    let dictionary7 = [Int: Int].keyValuePairs(Array(1...7).map { ($0, $0) })

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.observedGreenRoomOffChanged(off: false)
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([5])

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary7)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([5, 7])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_ScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.isScale .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.observedGreenRoomOffChanged(off: false)
    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([15])

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 20)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([15, 20])
  }

  func testCreateVideoViewController_RTMPStreamDefaultsToHLS() {
    // Step 1: Configure with an rtmp event stream
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.isRtmp .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(event: event, userId: nil)

    guard let hlsStreamType = event.hlsUrl.flatMap(LiveStreamType.hlsStream) else {
      XCTFail("HLS url should exist")
      return
    }

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateFirebaseFailedToInitialize() {
    self.vm.inputs.firebaseAppFailedToInitialize()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.initializationFailed])
  }

  func testCreateFirebasePresenceRef_LoggedOut() {
    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.createPresenceReference.assertValueCount(0)

    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)
    self.vm.inputs.setFirebaseUserId(userId: "123")

    let ref = FirebaseRefConfig(ref: "/watching/123", orderBy: "")

    self.createPresenceReference.assertValues([ref])
  }

  func testCreateFirebasePresenceRef_LoggedIn() {
    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(event: event, userId: 123)
    self.vm.inputs.viewDidLoad()

    self.createPresenceReference.assertValueCount(0)

    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)
    self.vm.inputs.setFirebaseUserId(userId: "123")

    let ref = FirebaseRefConfig(ref: "/watching/123", orderBy: "")

    self.createPresenceReference.assertValues([ref])
  }

  func testCreateFirebaseObservers_WhenLive() {
    let event = .template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)

    // All observer creation signals should only emit once
    self.createChatObservers.assertValueCount(1)
    self.createGreenRoomObservers.assertValueCount(1)
    self.createHLSObservers.assertValueCount(1)
    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(
      0, "Does not emit when not a scale event."
    )
  }

  func testDisableIdleTimer() {
    let event = LiveStreamEvent.template

    self.disableIdleTimer.assertValueCount(0)

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.disableIdleTimer.assertValues([true])

    self.vm.inputs.viewDidDisappear()

    self.disableIdleTimer.assertValues([true, false])
  }

  func testDoNotCreateFirebaseObservers_WhenNotLive() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)
      |> LiveStreamEvent.lens.hlsUrl .~ "http://www.live.mp4"

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    guard let replayUrl = event.replayUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    self.createVideoViewController.assertValues([hlsStreamType])

    self.createChatObservers.assertValueCount(0)
    self.createGreenRoomObservers.assertValueCount(0)
    self.createHLSObservers.assertValueCount(0)
    self.createNumberOfPeopleWatchingObservers.assertValueCount(0)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(0)
  }

  func testNumberOfPeopleObserver_WhenNotScaleEvent() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.isScale .~ false

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)

    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(0)
  }

  func testNumberOfPeopleObserver_WhenScaleEvent() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.startDate .~ Date().addingTimeInterval(-60*60)
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.isScale .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)

    self.createNumberOfPeopleWatchingObservers.assertValueCount(0)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(1)
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_LifeCycle() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.loading])

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.loading, .greenRoom])

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.loading, .greenRoom])

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: 5)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.loading, .greenRoom])

    self.vm.inputs.videoPlaybackStateChanged(state: .loading)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .greenRoom, .live(playbackState: .loading, startTime: 0)]
    )

    self.vm.inputs.videoPlaybackStateChanged(state: .playing)

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .greenRoom, .live(playbackState: .loading, startTime: 0),
        .live(playbackState: .playing, startTime: 0)]
    )

    self.vm.inputs.videoPlaybackStateChanged(state: .error(error: .sessionInterrupted))

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues(
      [.loading, .greenRoom, .live(playbackState: .loading, startTime: 0),
        .live(playbackState: .playing, startTime: 0), .error(error: .sessionInterrupted)
      ]
    )

  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_NotLive_NoReplay() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ false
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -16 * 60)

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.nonStarter])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_NotLive_Replay_NoReplayUrl() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ nil
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.nonStarter])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_ReplayState() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.startDate .~ Date(timeIntervalSinceNow: -60 * 60)

    self.vm.inputs.configureWith(event: event, userId: nil)
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

  //swiftlint:disable:next function_body_length
  func testReceivedFirebaseChatMessageDataSnapshot() {
    self.chatMessages.assertValueCount(0)

    self.vm.inputs.configureWith(event: .template, userId: nil)
    self.vm.inputs.viewDidLoad()

    let testSnapshot1 = TestFirebaseDataSnapshotType(
      key: "1", value: [
        "id": "1",
        "message": "Test chat message",
        "name": "Test Name",
        "profilePic": "http://www.kickstarter.com/picture.jpg",
        "timestamp": 1234234123,
        "userId": "id_1312341234321"
      ])
    let testSnapshot2 = TestFirebaseDataSnapshotType(
      key: "2", value: [
        "id": "2",
        "message": "Test chat message",
        "name": "Test Name",
        "profilePic": "http://www.kickstarter.com/picture.jpg",
        "timestamp": 1234234123,
        "userId": "id_1312341234321"
      ])
    let testSnapshot3 = TestFirebaseDataSnapshotType(
      key: "3", value: [
        "id": "3",
        "message": "Test chat message",
        "name": "Test Name",
        "profilePic": "http://www.kickstarter.com/picture.jpg",
        "timestamp": 1234234123,
        "userId": "id_1312341234321"
      ])

    self.backgroundQueueScheduler.advance()

    self.vm.inputs.receivedChatMessageSnapshot(chatMessage: testSnapshot1)
    self.scheduler.advance()
    self.vm.inputs.receivedChatMessageSnapshot(chatMessage: testSnapshot2)
    self.scheduler.advance()
    self.vm.inputs.receivedChatMessageSnapshot(chatMessage: testSnapshot3)
    self.scheduler.advance()

    self.scheduler.advance(by: .seconds(2))

    self.chatMessages.assertValueCount(1)
    XCTAssertTrue(self.chatMessages.lastValue?.isEmpty == .some(false))
    XCTAssertTrue(self.chatMessages.lastValue?.count == .some(3))
    XCTAssertEqual(self.chatMessages.lastValue?.first?.id, "1")

    self.vm.inputs.receivedChatMessageSnapshot(chatMessage: testSnapshot1)
    self.scheduler.advance()
    self.vm.inputs.receivedChatMessageSnapshot(chatMessage: testSnapshot2)
    self.scheduler.advance()

    self.scheduler.advance(by: .seconds(1))

    self.chatMessages.assertValueCount(1)

    self.scheduler.advance(by: .seconds(1))

    self.chatMessages.assertValueCount(2)

    XCTAssertTrue(self.chatMessages.lastValue?.count == .some(2))
    XCTAssertEqual(self.chatMessages.lastValue?.last?.id, "2")
  }

  func testWriteChatMessageToFirebase() {
    let event = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.writeChatMessageToFirebaseDbRef.assertValueCount(0)
    self.writeChatMessageToFirebaseRefConfig.assertValueCount(0)
    self.writeChatMessageToFirebaseMessageData.assertValueCount(0)

    self.vm.inputs.configureWith(event: event, userId: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.createdDatabaseRef(ref: TestFirebaseDatabaseReferenceType(),
                                      serverValue: TestFirebaseServerValueType.self)
    self.vm.inputs.configureChatUserInfo(info: (userId: 123, name: "Chat Name",
                                                profilePictureUrl: "http://www.kickstarter.com/avatar.jpg"))
    self.vm.inputs.sendChatMessage(message: "New chat message")

    self.writeChatMessageToFirebaseDbRef.assertValueCount(1)
    self.writeChatMessageToFirebaseRefConfig.assertValueCount(1)
    self.writeChatMessageToFirebaseMessageData.assertValueCount(1)

    XCTAssertEqual(123, self.writeChatMessageToFirebaseMessageData.lastValue?["userId"] as? Int)
    XCTAssertEqual("Chat Name", self.writeChatMessageToFirebaseMessageData.lastValue?["name"] as? String)
    XCTAssertEqual("http://www.kickstarter.com/avatar.jpg", self.writeChatMessageToFirebaseMessageData
      .lastValue?["profilePictureUrl"] as? String)
    XCTAssertEqual("New chat message", self.writeChatMessageToFirebaseMessageData
      .lastValue?["message"] as? String)

    guard let timestamp = self.writeChatMessageToFirebaseMessageData
      .lastValue?["timestamp"] as? [AnyHashable:Any] else {
      XCTFail()
      return
    }

    XCTAssertEqual(12345678, timestamp["timestamp"] as? Int)
  }
}
