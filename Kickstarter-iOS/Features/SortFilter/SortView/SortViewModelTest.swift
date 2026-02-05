import Combine
@testable import Kickstarter_Framework
import XCTest

final class SortViewModelTest: XCTestCase {
  private let sortOptions = ConcreteSortOption.allCases
  private var viewModel: SortViewModel<ConcreteSortOption>!

  override func setUp() {
    super.setUp()

    self.viewModel = SortViewModel(
      sortOptions: self.sortOptions,
      selectedSortOption: ConcreteSortOption.sortOne
    )
  }

  func testSortOptions() throws {
    XCTAssertEqual(self.viewModel.sortOptions, self.sortOptions)
  }

  func testSortOptionSelected() throws {
    var cancellables: [AnyCancellable] = []

    var optionSelected: ConcreteSortOption? = nil
    let expectation = expectation(description: "Waiting for a sort option selected")
    self.viewModel.selectedSortOption.sink { option in
      optionSelected = option
      expectation.fulfill()
    }
    .store(in: &cancellables)

    self.viewModel.selectSortOption(.sortThree)
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(optionSelected, .sortThree)
  }

  func testCloseTapped() throws {
    var cancellables: [AnyCancellable] = []

    var didCloseTapped = false
    let expectation = expectation(description: "Waiting for close to be tapped")
    self.viewModel.closeTapped.sink { _ in
      didCloseTapped = true
      expectation.fulfill()
    }
    .store(in: &cancellables)

    self.viewModel.close()
    waitForExpectations(timeout: 0.1)
    XCTAssertEqual(didCloseTapped, true)
  }
}
