import Combine
@testable import Kickstarter_Framework
import XCTest

final class FilterCategoryViewModelTest: XCTestCase {
  private var testCategories = [
    FilterCategory(id: "1", name: "Art"),
    FilterCategory(id: "2", name: "Design"),
    FilterCategory(id: "3", name: "Technology"),
    FilterCategory(id: "4", name: "Music"),
    FilterCategory(id: "5", name: "Film")
  ]

  func testLoadingWhenCategoriesEmpty() throws {
    let viewModel = FilterCategoryViewModel(with: [])

    XCTAssertEqual(viewModel.isLoading, true)
  }

  func testNotLoadingWhenCategories() throws {
    let viewModel = FilterCategoryViewModel(with: self.testCategories)

    XCTAssertEqual(viewModel.isLoading, false)
  }

  func testSelectedCategory() throws {
    let artCategory = FilterCategory(id: "1", name: "Art")
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)
    var selectedCategory: FilterCategory? = nil
    let expectation = expectation(description: "Waiting for a category")
    viewModel.selectedCategory.sink { category in
      selectedCategory = category
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.selectCategory(artCategory)
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(selectedCategory, artCategory)
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
    let artCategory = FilterCategory(id: "1", name: "Art")
    var cancellables: [AnyCancellable] = []

    let viewModel = FilterCategoryViewModel(with: self.testCategories)

    var selectedCategory: FilterCategory? = nil
    let expectation = expectation(description: "Waiting for reset")
    expectation.expectedFulfillmentCount = 2
    viewModel.selectedCategory.sink { category in
      selectedCategory = category
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.selectCategory(artCategory)
    viewModel.resetSelection()
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(selectedCategory, nil)
  }
}
