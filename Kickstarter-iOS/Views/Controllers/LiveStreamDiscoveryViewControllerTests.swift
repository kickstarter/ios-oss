@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream
import Prelude
import Result
import XCTest

internal final class LiveStreamDiscoveryViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 19

    let liveEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60).date
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.name .~ "Comin‘ to you live!"
      |> LiveStreamEvent.lens.creator.name .~ "A creator with a really long name to wrap onto two lines"
      |> LiveStreamEvent.lens.numberPeopleWatching .~ 1428

    let futureEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.name .~ "Future live event!"
    let pastEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60 * 24).date
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.com"
      |> LiveStreamEvent.lens.name .~ "We were live, but we aren‘t anymore. Check out our replay!"

    let events = [futureEvent, liveEvent, pastEvent]

    let liveStreamService = MockLiveStreamService(fetchEventsResult: .success(events))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, liveStreamService: liveStreamService) {

        let vc = Storyboard.LiveStreamDiscovery.instantiate(LiveStreamDiscoveryViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        vc.isActive(true)
        parent.view.frame.size.height = device == .pad ? 1_500 : 1_100

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NumberPeopleWatchingHidden() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 19

    let liveEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60).date
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.name .~ "Comin‘ to you live!"
      |> LiveStreamEvent.lens.creator.name .~ "A creator with a really long name to wrap onto two lines"
      |> LiveStreamEvent.lens.numberPeopleWatching .~ nil

    let futureEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.name .~ "Future live event!"
    let pastEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60 * 24).date
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.com"
      |> LiveStreamEvent.lens.name .~ "We were live, but we aren‘t anymore. Check out our replay!"

    let events = [futureEvent, liveEvent, pastEvent]

    let liveStreamService = MockLiveStreamService(fetchEventsResult: .success(events))

    combos([Language.en], [Device.phone4_7inch, Device.phone5_8inch]).forEach { language, device in
      withEnvironment(language: language, liveStreamService: liveStreamService) {

        let vc = Storyboard.LiveStreamDiscovery.instantiate(LiveStreamDiscoveryViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        vc.isActive(true)
        parent.view.frame.size.height = device == .pad ? 1_500 : 1_100

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
