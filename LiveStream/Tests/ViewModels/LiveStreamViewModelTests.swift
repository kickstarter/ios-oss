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

  override func setUp() {
    super.setUp()

    self.vm = LiveStreamViewModel(scheduler: scheduler)

    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.createGreenRoomObservers.observe(self.createGreenRoomObservers.observer)
    self.vm.outputs.createHLSObservers.observe(self.createHLSObservers.observer)
    self.vm.outputs.createNumberOfPeopleWatchingObservers.observe(
      self.createNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.createScaleNumberOfPeopleWatchingObservers.observe(
      self.createScaleNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observe(
      self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observer)
  }

  func testCreateVideoViewController_UnderMaxOpenTokViews() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    let dictionary15 = NSMutableDictionary()
    Array(1...15).forEach { dictionary15.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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

  // FIXME: make a test for over/under max opentok views when it is a scale event

  func testCreateVideoViewController_OverMaxOpenTokViews() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    let dictionary15 = NSMutableDictionary()
    Array(1...15).forEach { dictionary15.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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

  func testCreateVideoViewController_TogglingGreenRoom() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    self.vm.inputs.configureWith(
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createVideoViewController.assertValueCount(0)

    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    self.createVideoViewController.assertValueCount(0)

    self.scheduler.advanceByInterval(10)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)
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
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.observedGreenRoomOffChanged(off: false)
    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 15)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([15])

    self.vm.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: 20)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValues([15, 20])
  }









  func testOpenTokStream_UnderMaxOpenTokViews() {
    let event = .template
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.maxOpenTokViewers .~ 10

    let dictionary5 = NSMutableDictionary()
    Array(1...5).forEach { dictionary5.setValue(Int($0), forKey: String($0)) }

    let dictionary20 = NSMutableDictionary()
    Array(1...20).forEach { dictionary20.setValue(Int($0), forKey: String($0)) }

    // Step 1: Configure stream
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.assertValueCount(0)

    // Step 2: Deactivate green room
    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    // Step 3: Only once the number of people watching is set and its within the scale threshold
    // should the video view controller be created, it should be an OpenTok stream
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary5)

    let openTokStreamType = LiveStreamType.openTok(
      sessionConfig: .init(
        apiKey: event.openTok.appId,
        sessionId: event.openTok.sessionId,
        token: event.openTok.token
      )
    )

    self.createVideoViewController.assertValue(openTokStreamType)
    self.createVideoViewController.assertValueCount(1)

    // Step 4: Update the number of people watching above 300
    // This should not cause the video view controller to be recreated
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary20)

    self.createVideoViewController.assertValueCount(1)
    self.removeVideoViewController.assertValueCount(0)
  }

  func testOpenTokStreamAfterScale() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    let dictionary200 = NSMutableDictionary()
    Array(1...200).forEach { dictionary200.setValue(Int($0), forKey: String($0)) }

    let dictionary250 = NSMutableDictionary()
    Array(1...250).forEach { dictionary250.setValue(Int($0), forKey: String($0)) }

    let dictionary350 = NSMutableDictionary()
    Array(1...350).forEach { dictionary350.setValue(Int($0), forKey: String($0)) }

    XCTAssert(event.stream.maxOpenTokViewers == 300, "Maximum viewers before switch to HLS is 300")

    // Step 1: Configure stream and set the initial number of people watching below 300
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

    // Step 2: Deactivate green room
    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    // Step 3: Only once the number of people watching is set and its within the scale threshold
    // should the video view controller be created, it should be an HLS stream due to being above threshold
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary350)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

    self.createVideoViewController.assertValue(hlsStreamType)
    self.createVideoViewController.assertValueCount(1)

    // Step 4: Update the number of people watching to a number below the threshold
    // This should never cause the video view controller to be recreated
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary250)
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary200)

    self.createVideoViewController.assertValue(hlsStreamType)
    self.createVideoViewController.assertValueCount(1)
    self.removeVideoViewController.assertValueCount(0)
  }

  func testNumberOfPeopleCountTimeout() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    XCTAssert(event.stream.maxOpenTokViewers == 300, "Maximum viewers before switch to HLS is 300")

    // Step 1: Configure stream and set the initial number of people watching below 300
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
    self.vm.inputs.viewDidLoad()

    // Step 2: Deactivate green room
    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    // Step 3: Number of people is not determined in time so if we wait long enough it should create an HLS
    // stream

    self.createVideoViewController.assertValues([])
    self.scheduler.advanceByInterval(10)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)
    self.createVideoViewController.assertValues([hlsStreamType])

    // Step 4: Update the number of people watching above 300
    // This should not cause the view video controller to be recreated
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: 400)

    self.createVideoViewController.assertValueCount(1)
    self.removeVideoViewController.assertValueCount(0)

    // Step 5: Setting the hlsUrl again should remove the existing video view controller and create a new one
    self.vm.inputs.observedHlsUrlChanged(hlsUrl: "http://www.kickstarter.com")

    let newHLSStreamType = LiveStreamType.hlsStream(hlsStreamUrl: "http://www.kickstarter.com")

    self.createVideoViewController.assertValues([hlsStreamType, newHLSStreamType])
    self.createVideoViewController.assertValueCount(2)
    self.removeVideoViewController.assertValueCount(0)
  }

//  func testRTMPStreamDefaultsToHLS() {
//    // Step 1: Configure with an rtmp event stream
//    let event = LiveStreamEvent.template
//      |> LiveStreamEvent.lens.stream.isRtmp .~ true
//
//    self.vm.inputs.viewDidLoad()
//    self.vm.inputs.configureWith(app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event)
//
//    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)
//
//    // Step 2: Deactivate green room
//    // One video view controller of type HLS should be created
//    self.vm.inputs.observedGreenRoomOffChanged(off: true)
//    self.createVideoViewController.assertValue(hlsStreamType)
//    self.createVideoViewController.assertValueCount(1)
//
//    // Step 3: Activate green room
//    // Video view controller should be removed
//    self.vm.inputs.observedGreenRoomOffChanged(off: false)
//    self.removeVideoViewController.assertValueCount(1)
//
//    // Step 4: Deactivate green room
//    // A new HLS video view controller should be created
//    self.vm.inputs.observedGreenRoomOffChanged(off: true)
//    self.createVideoViewController.assertValues([hlsStreamType, hlsStreamType])
//  }

  func testCreateFirebaseObservers() {
    // Step 1: Configure with the firebase app and event
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
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
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(0)
  }

  func testNumberOfPeopleObserver_WhenScaleEvent() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.isScale .~ true

    self.vm.inputs.configureWith(
      app: TestFirebaseAppType(), databaseRef: TestFirebaseDatabaseReferenceType(), event: event
    )
    self.vm.inputs.viewDidLoad()

    self.createNumberOfPeopleWatchingObservers.assertValueCount(0)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(1)
  }
}
