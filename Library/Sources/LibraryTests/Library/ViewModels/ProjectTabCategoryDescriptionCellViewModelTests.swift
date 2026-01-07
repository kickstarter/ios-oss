@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectTabCategoryDescriptionCellViewModelTests: TestCase {
  fileprivate let vm: ProjectTabCategoryDescriptionCellViewModelType =
    ProjectTabCategoryDescriptionCellViewModel()

  fileprivate let categoryLabelText = TestObserver<String, Never>()
  fileprivate let descriptionLabelText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.categoryLabelText.observe(self.categoryLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
  }

  func testOutput_CategoryLabelText() {
    let environmentalCommitment = ProjectTabCategoryDescription(
      description: "Hello World",
      category: .environmentallyFriendlyFactories,
      id: 0
    )

    self.vm.inputs.configureWith(value: environmentalCommitment)

    self.categoryLabelText.assertValues([ProjectTabCategory.environmentallyFriendlyFactories.rawValue])
  }

  func testOutput_DescriptionLabelText() {
    let description = "Hello World"
    let environmentalCommitment = ProjectTabCategoryDescription(
      description: description,
      category: .environmentallyFriendlyFactories,
      id: 0
    )

    self.vm.inputs.configureWith(value: environmentalCommitment)

    self.descriptionLabelText.assertValues([description])
  }
}
