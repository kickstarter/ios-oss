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
  private let createFirebaseAppAndConfigureDatabaseReference = TestObserver<FirebaseAppType, NoError>()
  private let removeVideoViewController = TestObserver<(), NoError>()
  private let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = TestObserver<Int, NoError>()

  override func setUp() {
    super.setUp()

    self.vm = LiveStreamViewModel(scheduler: scheduler)

    self.vm.outputs.removeVideoViewController.observe(self.removeVideoViewController.observer)
    self.vm.outputs.createVideoViewController.observe(self.createVideoViewController.observer)
    self.vm.outputs.createFirebaseAppAndConfigureDatabaseReference.observe(
      self.createFirebaseAppAndConfigureDatabaseReference.observer)
    self.vm.outputs.createGreenRoomObservers.observe(self.createGreenRoomObservers.observer)
    self.vm.outputs.createHLSObservers.observe(self.createHLSObservers.observer)
    self.vm.outputs.createNumberOfPeopleWatchingObservers.observe(
      self.createNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.createScaleNumberOfPeopleWatchingObservers.observe(
      self.createScaleNumberOfPeopleWatchingObservers.observer)
    self.vm.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observe(
      self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observer)
  }

  func testOpenTokStreamBeforeScale() {
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    let dictionary300 = NSMutableDictionary()
    Array(1...300).forEach { dictionary300.setValue(Int($0), forKey: String($0)) }

    let dictionary200 = NSMutableDictionary()
    Array(1...200).forEach { dictionary200.setValue(Int($0), forKey: String($0)) }

    let dictionary250 = NSMutableDictionary()
    Array(1...250).forEach { dictionary250.setValue(Int($0), forKey: String($0)) }

    let dictionary350 = NSMutableDictionary()
    Array(1...350).forEach { dictionary350.setValue(Int($0), forKey: String($0)) }

    let dictionary400 = NSMutableDictionary()
    Array(1...400).forEach { dictionary400.setValue(Int($0), forKey: String($0)) }

    XCTAssert(event.stream.maxOpenTokViewers == 300, "Maximum viewers before switch to HLS is 300")

    // Step 1: Configure stream and set the initial number of people watching below 300
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), event: event)
    self.vm.inputs.viewDidLoad()

    // Step 2: Deactivate green room
    self.vm.inputs.observedGreenRoomOffChanged(off: true)

    // Step 3: Only once the number of people watching is set and its within the scale threshold
    // should the video view controller be created, it should be an OpenTok stream
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary250)

    let openTokStreamType = LiveStreamType.openTok(sessionConfig:
      OpenTokSessionConfig(
        apiKey: event.openTok.appId,
        sessionId: event.openTok.sessionId,
        token: event.openTok.token)
    )

    self.createVideoViewController.assertValue(openTokStreamType)
    self.createVideoViewController.assertValueCount(1)

    // Step 4: Update the number of people watching above 300
    // This should not cause the video view controller to be recreated
    self.vm.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: dictionary400)

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
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), event: event)
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
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), event: event)
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
    self.removeVideoViewController.assertValueCount(1)
  }

  func testRTMPStreamDefaultsToHLS() {
    // Step 1: Configure with an rtmp event stream
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.isRtmp .~ true

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(app: TestFirebaseAppType(), event: event)

    let hlsStreamType = LiveStreamType.hlsStream(hlsStreamUrl: event.stream.hlsUrl)

    // Step 2: Deactivate green room
    // One video view controller of type HLS should be created
    self.vm.inputs.observedGreenRoomOffChanged(off: true)
    self.createVideoViewController.assertValue(hlsStreamType)
    self.createVideoViewController.assertValueCount(1)

    // Step 3: Activate green room
    // Video view controller should be removed
    self.vm.inputs.observedGreenRoomOffChanged(off: false)
    self.removeVideoViewController.assertValueCount(1)

    // Step 4: Deactivate green room
    // A new HLS video view controller should be created
    self.vm.inputs.observedGreenRoomOffChanged(off: true)
    self.createVideoViewController.assertValues([hlsStreamType, hlsStreamType])
  }

  func testCreateFirebaseObservers() {
    // Step 1: Configure with the firebase app and event
    let app = TestFirebaseAppType()
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(app: app, event: event)

    self.createFirebaseAppAndConfigureDatabaseReference.assertValueCount(1)

    // Step 2: Configure the firebase database reference
    let dbRef = TestFirebaseDatabaseReferenceType()
    self.vm.inputs.setFirebaseDatabaseRef(ref: dbRef)

    // All observer creation signals should only emit once
    self.createGreenRoomObservers.assertValueCount(1)
    self.createHLSObservers.assertValueCount(1)
    self.createNumberOfPeopleWatchingObservers.assertValueCount(1)
    self.createScaleNumberOfPeopleWatchingObservers.assertValueCount(
      0, "createScaleNumberOfPeopleWatchingObservers should not emit as this is not a scale event")
  }
}
