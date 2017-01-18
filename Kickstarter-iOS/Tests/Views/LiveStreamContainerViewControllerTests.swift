import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream

internal final class LiveStreamContainerViewControllerTests: TestCase {

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

  func testReplay() {
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 86_400)
      |> Project.LiveStream.lens.isLiveNow .~ false
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.stream.hasReplay .~ true
      |> LiveStreamEvent.lens.stream.liveNow .~ false
      |> LiveStreamEvent.lens.stream.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.stream.name .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.stream.description .~ ("175 char max. 175 char max 175 char max message with " +
        "a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!")
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    let devices = [Device.phone4_7inch, .phone4inch, .pad]
    let orientations = [Orientation.landscape, .portrait]

    combos(Language.allLanguages, devices, orientations).forEach { lang, device, orientation in
      withEnvironment(language: lang, liveStreamService: liveStreamService) {
        let vc = LiveStreamContainerViewController.configuredWith(project: .template,
                                                                  liveStream: liveStream,
                                                                  event: liveStreamEvent)

        let (parent, _) = traitControllers(device: device, orientation: orientation, child: vc)
        vc.liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: nil, numberOfPeople: 2_532)
        self.scheduler.advance()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(lang)_device_\(device)_orientation_\(orientation)"
        )
      }
    }
  }

  func testLive() {
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 86_400)
      |> Project.LiveStream.lens.isLiveNow .~ true
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.stream.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.name .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.stream.description .~ ("175 char max. 175 char max 175 char max message with " +
        "a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!")
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    let devices = [Device.phone4_7inch, .phone4inch, .pad]
    let orientations = [Orientation.landscape, .portrait]

    combos(Language.allLanguages, devices, orientations).forEach { lang, device, orientation in
      withEnvironment(language: lang, liveStreamService: liveStreamService) {
        let vc = LiveStreamContainerViewController.configuredWith(project: .template,
                                                                  liveStream: liveStream,
                                                                  event: liveStreamEvent)

        let (parent, _) = traitControllers(device: device, orientation: orientation, child: vc)
        vc.liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: nil, numberOfPeople: 2_532)
        self.scheduler.advance()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(lang)_device_\(device)_orientation_\(orientation)"
        )
      }
    }
  }

  func testPlaybackStates() {

    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 86_400)
      |> Project.LiveStream.lens.isLiveNow .~ true
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.stream.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.stream.liveNow .~ true
      |> LiveStreamEvent.lens.stream.name .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.stream.description .~ ("175 char max. 175 char max 175 char max message with " +
        "a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!")
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    let playbackStates: [LiveStreamViewControllerState] = [
      .greenRoom,
      .loading,
      .live(playbackState: .playing, startTime: 0)
    ]

    combos(Language.allLanguages, playbackStates).forEach { lang, state in
      withEnvironment(language: lang, liveStreamService: liveStreamService) {
        let vc = LiveStreamContainerViewController.configuredWith(project: .template,
                                                                  liveStream: liveStream,
                                                                  event: liveStreamEvent)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        vc.liveStreamViewControllerStateChanged(controller: nil, state: state)
        vc.liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: nil, numberOfPeople: 2_532)
        self.scheduler.advance()

        let stateIdentifier = state == .greenRoom ? "greenRoom"
          : state == .loading ? "loading"
          : "playing"

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(lang)_state_\(stateIdentifier)"
        )
      }
    }
  }
}
