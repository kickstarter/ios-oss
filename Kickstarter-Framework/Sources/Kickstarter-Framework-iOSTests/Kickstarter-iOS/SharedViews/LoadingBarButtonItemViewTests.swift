@testable import Kickstarter_Framework
@testable import LibraryTestHelpers
import SnapshotTesting
import UIKit
import XCTest

internal final class LoadingBarButtonItemViewTests: TestCase {
  func testView_disabled() {
    let loadingBarButtonItemView = LoadingBarButtonItemView.instantiate()
    loadingBarButtonItemView.setTitle(title: "Button")
    loadingBarButtonItemView.setIsEnabled(isEnabled: false)

    assertSnapshot(of: loadingBarButtonItemView, as: .image)
  }

  func testView_enabled() {
    let loadingBarButtonItemView = LoadingBarButtonItemView.instantiate()
    loadingBarButtonItemView.setTitle(title: "Button")
    loadingBarButtonItemView.setIsEnabled(isEnabled: true)

    assertSnapshot(of: loadingBarButtonItemView, as: .image)
  }

  func testView_loading() {
    let loadingBarButtonItemView = LoadingBarButtonItemView.instantiate()
    loadingBarButtonItemView.setTitle(title: "Button")
    loadingBarButtonItemView.startAnimating()

    assertSnapshot(of: loadingBarButtonItemView, as: .image)
  }
}
