import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class LiveStreamCountdownViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)

    UIView.setAnimationsEnabled(false)

    self.recordMode = true
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testSomething() {

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { lang, device in

      let vc =
        LiveStreamCountdownViewController.configuredWith(project: .template, liveStream: .template)

      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      FBSnapshotVerifyView(vc.view, identifier: "lang_\(lang)_device_\(device)")
    }
  }
}
