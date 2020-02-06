@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ActivityFriendBackingViewModelTests: TestCase {
  fileprivate let vm: ActivityFriendBackingViewModelType = ActivityFriendBackingViewModel()

  fileprivate let cellAccessibilityLabel = TestObserver<String, Never>()
  fileprivate let friendTitleLabel = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.friendTitle.map { $0.string }.observe(self.friendTitleLabel.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
  }

  func testFrientTitle_ParentCategory() {
    let games = Project.Category.template
      |> \.id .~ 12
      |> \.name .~ "Games"

    self.vm.inputs.configureWith(
      activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> \.category .~ games)
    )

    self.friendTitleLabel.assertValues(["Blob backed a Games project."])
  }

  func testFrientTitle_SubCategory() {
    let illustration = Project.Category.template
      |> \.id .~ 25
      |> \.name .~ "Illustration"
      |> \.parentId .~ 1
      |> \.parentName .~ "Art"

    self.vm.inputs.configureWith(
      activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> \.category .~ illustration)
    )

    self.friendTitleLabel.assertValues(["Blob backed an Art project."])
  }

  func testAccessibility() {
    let games = Project.Category.template
      |> \.id .~ 12
      |> \.name .~ "Games"

    self.vm.inputs.configureWith(
      activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> \.category .~ games)
    )

    self.cellAccessibilityLabel.assertValues(["Blob backed a Games project., The Project"])
  }
}
