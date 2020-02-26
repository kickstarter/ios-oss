@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionCellViewModelTests: TestCase {
  private let categoryTitleText = TestObserver<String, Never>()
  private let loadSubcategories = TestObserver<[String], Never>()

  private let vm: CategorySelectionCellViewModelType = CategorySelectionCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.categoryTitleText.observe(self.categoryTitleText.observer)
    self.vm.outputs.loadSubCategories.observe(self.loadSubcategories.observer)
  }

  func testTitleText() {
    let category = Category.art

    self.categoryTitleText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: category)

    self.categoryTitleText.assertValues(["Art"])
  }

  func testLoadSubcategories() {
    let category = Category.art

    self.loadSubcategories.assertDidNotEmitValue()

    self.vm.inputs.configure(with: category)

    self.loadSubcategories.assertValues([["All Art Projects", "Illustration"]])
  }
}

