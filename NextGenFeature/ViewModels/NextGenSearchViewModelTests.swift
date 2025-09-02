import Library
@testable import NextGenFeature
import XCTest

// A service mock for both success + failure
private struct MockSearchService: NextGenProjectSearchType {
  enum State {
    case success(delay: Int, results: (String) -> [NextGenSearchResult])
    case failure(delay: Int, error: Error)
  }

  let state: State

  func searchProjects(matching term: String) async throws -> [NextGenSearchResult] {
    switch self.state {
    case let .success(delay, results):
      // pretend network call delay
      try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)

      return results(term)
    case let .failure(delay, error):
      // pretend network call delay, but then throw
      try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)

      throw error
    }
  }
}

final class NextGenSearchViewModelTests: XCTestCase {
  /// `TestCase` base isn't accessible in this feature module, so we just reset the env ourselves.
  override func setUp() {
    super.setUp()

    AppEnvironment.resetStackForUnitTests()
  }

  @MainActor
  func testDebouncedSearch_setsLoadingAndResults() async {
    let service = MockSearchService(
      state: .success(delay: 10) { term in
        [NextGenSearchResult(id: UUID(), name: "\(term)")]
      }
    )
    let vm = NextGenSearchViewModel(service: service)

    XCTAssertEqual(vm.results, [])
    XCTAssertEqual(vm.statusText, "Idle")
    XCTAssertEqual(vm.isLoading, false)

    vm.searchTextChanged("ca")
    vm.searchTextChanged("cats")

    // debounce (250ms) + our fake delay (10ms)
    try? await Task.sleep(nanoseconds: 300_000_000)

    // should look “done”
    XCTAssertFalse(vm.isLoading)
    XCTAssertTrue(vm.statusText.contains("Found")) /// `Found` is being harcoded in the view
    XCTAssertEqual(vm.results.count, 1)
  }

  @MainActor
  func testEmptyInput_clearsResultsAndStatus_stopsLoading() async {
    let service = MockSearchService(
      state: .success(delay: 10) { term in
        [NextGenSearchResult(id: UUID(), name: "\(term)")]
      }
    )
    let vm = NextGenSearchViewModel(service: service)

    // set an input to be clear
    vm.searchTextChanged("abc")

    try? await Task.sleep(nanoseconds: 300_000_000)

    XCTAssertGreaterThan(vm.results.count, 0)

    vm.searchTextChanged("")

    // delay to let the UI settle
    vm.searchTextChanged("")

    try? await Task.sleep(nanoseconds: 300_000_000)

    XCTAssertEqual(vm.results, [])
    XCTAssertEqual(vm.statusText, "Idle") /// `Idle` is being harcoded in the view
    XCTAssertEqual(vm.isLoading, false)
  }

  @MainActor
  func testServiceError_setsStatusTextError_andStopsLoading() async {
    let error = NSError(
      domain: "com.kickstarter.tests",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: "Network error"]
    )
    let service = MockSearchService(state: .failure(delay: 10, error: error))
    let vm = NextGenSearchViewModel(service: service)

    vm.searchTextChanged("cats")

    try? await Task.sleep(nanoseconds: 300_000_000)

    XCTAssertFalse(vm.isLoading)
    XCTAssertTrue(vm.statusText.hasPrefix("Error:")) /// `Error` is being harcoded in the view
    XCTAssertEqual(vm.results.count, 0)
  }
}
