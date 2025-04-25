import Combine
@testable import Kickstarter_Framework
import XCTest

final class FilterCategoryViewModelTest: XCTestCase {
  private var testCategories = ConcreteFilterCategory.allCases

  func testLoadingWhenCategoriesEmpty() throws {
    let viewModel = FilterCategoryViewModel<ConcreteFilterCategory>(with: [])

    XCTAssertEqual(viewModel.isLoading, true)
  }

  func testNotLoadingWhenCategories() throws {
    let viewModel = FilterCategoryViewModel(with: self.testCategories)

    XCTAssertEqual(viewModel.isLoading, false)
  }

  func testSelectedCategory() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)
    var selectedCategory: (ConcreteFilterCategory, subcategory: ConcreteFilterCategory?)? = nil
    let expectation = expectation(description: "Waiting for a category")
    viewModel.selectedCategory.sink { selection in
      selectedCategory = selection
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.selectCategory(.categoryFour)
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(selectedCategory?.0, .categoryFour)
  }
}
