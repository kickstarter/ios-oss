import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ActivityFriendBackingViewModelTests: TestCase {
  fileprivate let vm: ActivityFriendBackingViewModelType = ActivityFriendBackingViewModel()

  fileprivate let cellAccessibilityLabel = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
  }

  func testAccessibility() {
    self.vm.inputs.configureWith(activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> Project.lens.category .~ .games)
    )

    self.cellAccessibilityLabel.assertValues(["Blob backed a Games project., The Project"])
  }
}
