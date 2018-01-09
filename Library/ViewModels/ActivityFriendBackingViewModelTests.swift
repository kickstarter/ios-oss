import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ActivityFriendBackingViewModelTests: TestCase {
  fileprivate let vm: ActivityFriendBackingViewModelType = ActivityFriendBackingViewModel()

  fileprivate let cellAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let friendTitleLabel = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.friendTitle.map{ $0.string }.observe(self.friendTitleLabel.observer)
  }

  func testFrientTitle_ParentCategory() {
    let games = Category.template
      |> \.id .~ "12"
      |> \.name .~ "Games"
      |> \.subcategories
      .~ Category.SubcategoryConnection(totalCount: 1, nodes: [.tabletopGames])

    self.vm.inputs.configureWith(activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> Project.lens.category .~ games)

    )

    self.friendTitleLabel.assertValues(["Blob backed a Games project."])
  }

  func testFrientTitle_SubCategory() {
    let illustration = Category.template
      |> \.id .~ "25"
      |> \.name .~ "Illustration"
      |> \.parentId .~ "1"
      |> Category.lens.parent .~ ParentCategory(id: "1", name: "Art")

    self.vm.inputs.configureWith(activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> Project.lens.category .~ illustration)

    )

    self.friendTitleLabel.assertValues(["Blob backed an Art project."])
  }

  func testAccessibility() {
    let games = Category.template
      |> \.id .~ "12"
      |> \.name .~ "Games"
      |> \.subcategories
      .~ Category.SubcategoryConnection(totalCount: 1, nodes: [.tabletopGames])

    self.vm.inputs.configureWith(activity:
      .template
        |> Activity.lens.category .~ .backing
        |> Activity.lens.project .~ (.template |> Project.lens.category .~ games)
    )

    self.cellAccessibilityLabel.assertValues(["Blob backed a Games project., The Project"])
  }
}
