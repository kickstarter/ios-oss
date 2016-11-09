@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

internal final class SortPagerViewControllerTests: TestCase {
  private let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon, .mostFunded]

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testSortView() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Culture() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 1)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Story() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 11)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Entertainment() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 12)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_iPad_Landscape() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .pad, orientation: .landscape, child: controller)
        parent.view.frame.size.height = 50

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Culture_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 1)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Story_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 11)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testSortView_Entertainment_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: sorts)

        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 50

        controller.updateStyle(categoryId: 12)

        self.scheduler.advanceByInterval(0.1)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
