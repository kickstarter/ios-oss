import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ActivityFriendBackingViewModelTests: TestCase {
  private let vm: ActivityFriendBackingViewModelType = ActivityFriendBackingViewModel()

  private let cellAccessibilityLabel = TestObserver<String, NoError>()
  private let cellAccessibilityValue = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
  }

  func testAccessibility() {
    self.vm.inputs.configureWith(activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> Project.lens.category .~ .games)
    )

    self.cellAccessibilityLabel.assertValues(["Blob backed a Games project."])
    self.cellAccessibilityValue.assertValues(["The Project"])
  }
}
