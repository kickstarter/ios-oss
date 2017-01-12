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

  func testSomething() {
//    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { lang, device in
//      let vc = LiveStreamContainerViewController.configuredWith(project: .template,
//                                                                liveStream: .template,
//                                                                event: .template)
//
//      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
//      self.scheduler.advance()
//
//      FBSnapshotVerifyView(parent.view, identifier: "lang_\(lang)_device_\(device)")
//    }
  }
}
