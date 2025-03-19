import Combine
@testable import Kickstarter_Framework
import XCTest

final class SortViewModelTest: XCTestCase {
  func testSortOptions() throws {
    let viewModel = SortViewModel()
    XCTAssertEqual(viewModel.sortOptions, SortOption.allCases)
  }

  func testSortOptionSelected() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = SortViewModel()
    var optionSelected: SortOption? = nil
    let expectation = expectation(description: "Waiting for a sort option selected")
    viewModel.selectedSortOption.sink { option in
      optionSelected = option
      expectation.fulfill()
    }
    .store(in: &cancellables)

    viewModel.selectSortOption(.popularity)
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(optionSelected, .popularity)
  }

  func testCloseTapped() throws {
    var cancellables: [AnyCancellable] = []

    let viewModel = SortViewModel()
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
}
