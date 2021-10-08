@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPageViewControllerTests: TestCase {
  let vm: ProjectNavigationSelectorViewModelType = ProjectNavigationSelectorViewModel()

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

  func testProjectPageViewController_PortraitOrientation() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let vc = ProjectPageViewController()

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testProjectPageViewController_PortraitLandscape() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let vc = ProjectPageViewController()

        let (parent, _) = traitControllers(device: device, orientation: .landscape, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
