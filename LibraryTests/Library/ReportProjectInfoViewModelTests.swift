import Combine
import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class ReportProjectInfoViewModelTests: TestCase {
  private var viewModel: ReportProjectInfoViewModel!
  private var cancellables = Set<AnyCancellable>()

  override func setUp() {
    super.setUp()
    self.viewModel = ReportProjectInfoViewModel()
  }

  override func tearDown() {
    self.cancellables.removeAll()
    super.tearDown()
  }

  func testListItems_IsEmpty_BeforeViewDidLoad() {
    XCTAssertTrue(self.viewModel.listItems.isEmpty)
  }

  func testListItems_IsPopulated_AfterSuccessfulFetch() {
    let expectation = expectation(description: "listItems populated")

    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.viewModel.$listItems
        .filter { !$0.isEmpty }
        .first()
        .sink { items in
          XCTAssertFalse(items.isEmpty)
          expectation.fulfill()
        }
        .store(in: &self.cancellables)

      self.viewModel.inputs.viewDidLoad()
    }

    waitForExpectations(timeout: 1.0)
  }

  func testListItems_MapsCorrectly_Response() {
    let expectation = expectation(description: "listItems")

    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.viewModel.$listItems
        .filter { !$0.isEmpty }
        .first()
        .sink { items in
          XCTAssertEqual(items.first?.id, "project/post_funding_issues")
          XCTAssertNotNil(items.first?.subItems)

          expectation.fulfill()
        }
        .store(in: &self.cancellables)

      self.viewModel.inputs.viewDidLoad()
    }

    waitForExpectations(timeout: 1.0)
  }

  func testListItems_IsEmpty_OnError() {
    let expectation = expectation(description: "fetch completed")

    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .failure(.couldNotParseJSON))) {
      self.viewModel.$isLoading
        .filter { !$0 }
        .dropFirst()
        .first()
        .sink { _ in
          XCTAssertTrue(self.viewModel.listItems.isEmpty)
          expectation.fulfill()
        }
        .store(in: &self.cancellables)

      self.viewModel.inputs.viewDidLoad()
    }

    waitForExpectations(timeout: 1.0)
  }

  func testIsLoading_IsFalse_BeforeViewDidLoad() {
    XCTAssertFalse(self.viewModel.isLoading)
  }

  func testIsLoading_IsTrue_ThenFalse_AfterViewDidLoad() {
    let expectation = expectation(description: "loading complete")
    var states: [Bool] = []

    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .success(.mock))) {
      self.viewModel.$isLoading
        .sink { isLoading in
          states.append(isLoading)
          if states.count == 3 { /// false (initial value), true, false
            expectation.fulfill()
          }
        }
        .store(in: &self.cancellables)

      self.viewModel.inputs.viewDidLoad()
    }

    waitForExpectations(timeout: 1.0)
    XCTAssertEqual(states, [false, true, false])
  }

  func testIsLoading_ReturnsFalse_OnError() {
    let expectation = expectation(description: "loading ends after error")

    withEnvironment(apiService: MockService(fetchFlaggingOptionsResult: .failure(.couldNotParseJSON))) {
      self.viewModel.$isLoading
        .filter { !$0 }
        .dropFirst()
        .first()
        .sink { _ in expectation.fulfill() }
        .store(in: &self.cancellables)

      self.viewModel.inputs.viewDidLoad()
    }

    waitForExpectations(timeout: 1.0)
    XCTAssertFalse(self.viewModel.isLoading)
  }
}
