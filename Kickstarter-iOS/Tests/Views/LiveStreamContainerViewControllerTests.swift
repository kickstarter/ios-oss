import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream

internal final class LiveStreamContainerViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    self.recordMode = true
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
      |> LiveStreamEvent.lens.stream.projectName .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.stream.description .~ "175 char max. 175 char max 175 char max message with a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!"
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    let devices = [Device.phone4_7inch, .phone4inch, .pad]
    let orientations = [Orientation.landscape, .portrait]
    
    combos(Language.allLanguages, devices, orientations).forEach { lang, device, orientation in
      withEnvironment(language: lang, liveStreamService: liveStreamService) {
        let vc = LiveStreamContainerViewController.configuredWith(project: .template,
                                                                  liveStream: liveStream,
                                                                  event: liveStreamEvent)

        let (parent, _) = traitControllers(device: device, orientation: orientation, child: vc)
        self.scheduler.advance()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(lang)_device_\(device)_orientation_\(orientation)"
        )
      }
    }
  }
}
