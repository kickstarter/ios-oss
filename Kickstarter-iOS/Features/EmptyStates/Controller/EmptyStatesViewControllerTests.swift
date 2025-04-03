@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class EmptyStatesViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testEmptyStates() {
    let emptyStates = [EmptyState.activity, .recommended, .starred, .socialDisabled, .socialNoPledges]

    combos(Language.allLanguages, emptyStates).forEach { language, emptyState in
      withEnvironment(language: language) {
        let controller = EmptyStatesViewController.configuredWith(emptyState: emptyState)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        assertSnapshot(matching: parent.view, as: .image, named: "_\(emptyState.rawValue)_lang_\(language)")
      }
    }
  }

  func testEmptyStates_iPad() {
    let emptyStates = [EmptyState.activity, .recommended, .starred, .socialDisabled, .socialNoPledges]

    combos(Language.allLanguages, emptyStates).forEach { language, emptyState in
      withEnvironment(language: language) {
        let controller = EmptyStatesViewController.configuredWith(emptyState: emptyState)
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)

        assertSnapshot(matching: parent.view, as: .image, named: "_\(emptyState.rawValue)_lang_\(language)")
      }
    }
  }
}
