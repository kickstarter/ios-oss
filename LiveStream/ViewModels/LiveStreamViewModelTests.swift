import ReactiveCocoa
import Result
import XCTest
import Prelude
@testable import LiveStream
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

private struct TestFirebaseAppType: FirebaseAppType {}
private struct TestFirebaseDatabaseReferenceType: FirebaseDatabaseReferenceType {}

internal final class LiveStreamViewModelTests: XCTestCase {
  private let scheduler = TestScheduler()
  private var vm: LiveStreamViewModelType!

  private let createGreenRoomObservers = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createHLSObservers = TestObserver<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>()
  private let createNumberOfPeopleWatchingObservers = TestObserver<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>()
  private let createScaleNumberOfPeopleWatchingObservers = TestObserver<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>()
  private let createVideoViewController = TestObserver<LiveStreamType, NoError>()
  private let removeVideoViewController = TestObserver<(), NoError>()
  private let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = TestObserver<Int, NoError>()
  private let notifyDelegateLiveStreamViewControllerStateChanged
    = TestObserver<LiveStreamViewControllerState, NoError>()

  override func setUp() {
    super.setUp()

    self.vm = LiveStreamViewModel(scheduler: scheduler)

    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.createGreenRoomObservers.observe(self.createGreenRoomObservers.observer)
    self.vm.outputs.createHLSObservers.observe(self.createHLSObservers.observer)
    self.vm.outputs.createNumberOfPeopleWatchingObservers
      .observe(self.createNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.createScaleNumberOfPeopleWatchingObservers
      .observe(self.createScaleNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged
      .observe(self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observer)
    self.vm.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observe(self.notifyDelegateLiveStreamViewControllerStateChanged.observer)
  }

  func testCreateVideoViewController_UnderMaxOpenTokViews() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ false

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    let dictionary15 = NSMutableDictionary()
    Array(1...15).forEach { dictionary15.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    let openTokStreamType = LiveStreamType.openTok(
      sessionConfig: .init(
        apiKey: event.openTok.appId,
        sessionId: event.openTok.sessionId,
        token: event.openTok.token
      )
    )

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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ true

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 5)

    let openTokStreamType = LiveStreamType.openTok(
      sessionConfig: .init(
        apiKey: event.openTok.appId,
        sessionId: event.openTok.sessionId,
        token: event.openTok.token
      )
    )

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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ false

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    let dictionary15 = NSMutableDictionary()
    Array(1...15).forEach { dictionary15.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ true
    |> LiveStreamEvent.lens.stream.hlsUrl .~ "http://www.stream.mp4"

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.createVideoViewController.assertValueCount(0)
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    let openTokStreamType = LiveStreamType.openTok(
      sessionConfig: .init(
        apiKey: event.openTok.appId,
        sessionId: event.openTok.sessionId,
        token: event.openTok.token
      )
    )

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: false)

    self.createVideoViewController.assertValues([openTokStreamType])
    self.removeVideoViewController.assertValueCount(1)
  }

  func testCreateVideoViewController_HlsUrlChanges() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary15 = NSMutableDictionary()
    Array(1...15).forEach { dictionary15.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary15)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.scheduler.advanceByInterval(10)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)
    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateVideoViewController_Replay() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ false
      |> LiveStreamEvent.lens.stream.hasReplay .~ true
      |> LiveStreamEvent.lens.stream.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.stream.startDate .~ (NSDate.init(timeIntervalSinceNow: -60 * 60))
      |> LiveStreamEvent.lens.stream.hlsUrl .~ "http://www.live.mp4"

    self.vm.inputs.configureWith(databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

    guard let replayUrl = event.stream.replayUrl else { XCTAssertTrue(false); return }
    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: replayUrl)

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_NonScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ false

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }
    let dictionary7 = NSMutableDictionary()
    Array(1...7).forEach { dictionary7.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.observedGreenRoomOffChanged(off: false)
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([5])

    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary7)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([5, 7])
  }

  func testNotifyDelegateLiveStreamNumberOfPeopleWatchingChanged_ScaleEvent() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10
      |> LiveStreamEvent.lens.stream.isScale .~ true

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
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
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.isRtmp .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(databaseRef: TestFirebaseDatabaseReferenceType(), event: event)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValues([hlsStreamType])
  }

  func testCreateFirebaseObservers() {
    // Step 1: Configure with the firebase app and event
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )

    // All observer creation signals should only emit once
    self.createGreenRoomObservers.assertValueCount(1)
    self.createHLSObservers.assertValueCount(1)
    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(0, "Does not emit when not a scale event.")
  }

  func testNumberOfPeopleObserver_WhenNotScaleEvent() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.isScale .~ false

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(0)
  }

  func testNumberOfPeopleObserver_WhenScaleEvent() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.isScale .~ true

    self.vm.inputs.configureWith(
      databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createNumberOfPeopleWatchingObservers.assertValueCount(0)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(1)
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_LifeCycle() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    self.vm.inputs.configureWith(databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

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

  func testNotifyDelegateLiveStreamViewControllerStateChanged_NonStarter() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ false
      |> LiveStreamEvent.lens.stream.hasReplay .~ false
      |> LiveStreamEvent.lens.stream.replayUrl .~ nil
      |> LiveStreamEvent.lens.stream.startDate .~ (NSDate.init(timeIntervalSinceNow: -16 * 60))

    self.vm.inputs.configureWith(databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamViewControllerStateChanged.assertValues([.nonStarter])
  }

  func testNotifyDelegateLiveStreamViewControllerStateChanged_ReplayState() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ false
      |> LiveStreamEvent.lens.stream.hasReplay .~ true
      |> LiveStreamEvent.lens.stream.replayUrl .~ "http://www.replay.mp4"
      |> LiveStreamEvent.lens.stream.startDate .~ (NSDate.init(timeIntervalSinceNow: -60 * 60))

    self.vm.inputs.configureWith(databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
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




  // FIXME: write test for hasreplay/replayurl weirdness
}
