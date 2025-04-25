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

  func testSeeResultsTapped() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)
    var didSeeResultsTapped = false
    let expectation = expectation(description: "Waiting for see results to be tapped")
    viewModel.seeResultsTapped.sink { _ in
      didSeeResultsTapped = true
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.seeResults()
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(didSeeResultsTapped, true)
  }

  func testCloseTapped() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)
    var didCloseTapped = false
    let expectation = expectation(description: "Waiting for close to be tapped")
    viewModel.closeTapped.sink { _ in
      didCloseTapped = true
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.close()
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(didCloseTapped, true)
  }

  func testReset() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)

    var selectedCategory: (ConcreteFilterCategory, subcategory: ConcreteFilterCategory?)? = nil
    let expectation = expectation(description: "Waiting for reset")
    expectation.expectedFulfillmentCount = 2
    viewModel.selectedCategory.sink { selection in
      selectedCategory = selection
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.selectCategory(.categoryFour)
    viewModel.resetSelection()
    waitForExpectations(timeout: 0.1)
    XCTAssertNil(selectedCategory)
  }
}
