import Combine
@testable import Library
import XCTest

struct TestEnvelope {
  let values: [Int]
  let cursor: Int?
  let total: Int

  init(values: [Int], cursor: Int?, total: Int = 42) {
    self.values = values
    self.cursor = cursor
    self.total = total
  }

  var publisher: AnyPublisher<TestEnvelope, ConcreteError> {
    return Just(self).setFailureType(to: ConcreteError.self)
      .delay(for: 0.01, tolerance: 0.01, scheduler: RunLoop.main)
      .eraseToAnyPublisher()
  }
}

struct ConcreteError: Error {}

final class PaginatorTests: XCTestCase {
  let valuesFromEnvelope: (TestEnvelope) -> [Int] = { $0.values }
  let cursorFromEnvelope: (TestEnvelope) -> Int? = { $0.cursor }
  let totalFromEnvelope: (TestEnvelope) -> Int? = { $0.total }

  func waitTinyInterval() {
    _ = XCTWaiter.wait(for: [expectation(description: "Wait a tiny interval of time.")], timeout: 0.05)
  }

  func testPaginator_initialResults_isUnloaded() {
    let paginator = Paginator<TestEnvelope, Int, Int?, ConcreteError, Int>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    XCTAssertEqual(paginator.results, .unloaded)
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [])
    XCTAssertEqual(paginator.results.total, nil)
  }

  func testPaginator_requestFirstPage_loadsFirstPage() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: nil, total: 3).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil, total: 3).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [], "Values should not have loaded yet")
    XCTAssertEqual(paginator.results.total, nil)

    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [1, 2, 3])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .allLoaded(values: [1, 2, 3], page: 1))
    XCTAssertEqual(paginator.results.total, 3)
  }

  func testPaginator_requestFirstPage_noResults_isEmpty() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [], "Values should not have loaded yet")
    XCTAssertEqual(paginator.results.total, nil)

    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .empty)
    XCTAssertEqual(paginator.results.total, 0)
  }

  func testPaginator_requestNextPage_hasCursor_loadsNextPage() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1, total: 9).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: 2, total: 9).publisher
        } else if cursor == 2 {
          return TestEnvelope(values: [7, 8, 9], cursor: nil, total: 9).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.results, .someLoaded(values: [1, 2, 3], cursor: 1, total: 9, page: 1))
    XCTAssertEqual(paginator.results.values, [1, 2, 3])
    XCTAssertEqual(paginator.results.total, 9)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .someLoaded(values: [1, 2, 3, 4, 5, 6], cursor: 2, total: 9, page: 2))
    XCTAssertEqual(paginator.results.total, 9)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .allLoaded(values: [1, 2, 3, 4, 5, 6, 7, 8, 9], page: 3))
    XCTAssertEqual(paginator.results.total, 9)
  }

  func testPaginator_requestNextPage_returnsNoCursor_finishes() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1, total: 6).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: nil, total: 6).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.results, .someLoaded(values: [1, 2, 3], cursor: 1, total: 6, page: 1))
    XCTAssertEqual(paginator.results.values, [1, 2, 3])
    XCTAssertEqual(paginator.results.total, 6)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .allLoaded(values: [1, 2, 3, 4, 5, 6], page: 2))
    XCTAssertEqual(paginator.results.total, 6)

    paginator.requestNextPage()
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results, .allLoaded(values: [1, 2, 3, 4, 5, 6], page: 2))
    XCTAssertEqual(paginator.results.total, 6)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(paginator.results.total, 6)
  }

  func testPaginator_requestNextPage_returnsNoResults_finishes() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1, total: 6).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: 2, total: 6).publisher
        } else if cursor == 2 {
          return TestEnvelope(values: [], cursor: 3, total: 6).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.results, .someLoaded(values: [1, 2, 3], cursor: 1, total: 6, page: 1))
    XCTAssertEqual(paginator.results.values, [1, 2, 3])
    XCTAssertEqual(paginator.results.total, 6)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.results.error)
    XCTAssertEqual(paginator.results, .someLoaded(values: [1, 2, 3, 4, 5, 6], cursor: 2, total: 6, page: 2))
    XCTAssertEqual(paginator.results.total, 6)

    paginator.requestNextPage()
    self.waitTinyInterval()

    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results, .allLoaded(values: [1, 2, 3, 4, 5, 6], page: 2))
    XCTAssertEqual(paginator.results.values, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(paginator.results.total, 6)
  }

  func testPaginator_cancel_cancelsPendingRequests() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)

    // Don't wait the time interval for the request to complete
    paginator.cancel()
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.values, [], "Cancel should have kept the new values from loading")

    // Now wait, and double-check
    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [], "Cancel should have kept the new values from loading")
  }

  func testPaginator_requestNextPage_whileLoading_doesNothing() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1, total: 6).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [4, 5, 6], cursor: nil, total: 6).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)

    paginator.requestNextPage()

    self.waitTinyInterval()
    XCTAssertEqual(
      paginator.results.values,
      [1, 2, 3],
      "Second page should not have loaded while first page was still loading"
    )
  }

  func testPaginator_requestFirstPage_whileLoading_cancelsPreviousRequest() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1, total: 6).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [4, 5, 6], cursor: nil, total: 6).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [1, 2, 3])
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results.total, 6)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)

    // Don't let it load, request the first page again
    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(
      paginator.results.values,
      [1, 2, 3],
      "Second page should not have loaded, because it should have been canceled by reloading the first page"
    )
  }

  func testPaginator_requestFirstPage_withError_setsError() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in
        Fail(outputType: TestEnvelope.self, failure: ConcreteError())
          .delay(for: 0.01, tolerance: 0.01, scheduler: RunLoop.main)
          .eraseToAnyPublisher()
      },
      requestFromCursor: { _ in Empty().eraseToAnyPublisher() }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.results.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [])
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results, .error(ConcreteError()))
    XCTAssertNotNil(paginator.results.error)
  }

  func testPaginator_requestNextPage_withError_setsError() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      totalFromEnvelope: totalFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { _ in
        Fail(outputType: TestEnvelope.self, failure: ConcreteError())
          .delay(for: 0.01, tolerance: 0.01, scheduler: RunLoop.main)
          .eraseToAnyPublisher()
      }
    )

    paginator.requestFirstPage(withParams: ())
    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [1, 2, 3])

    paginator.requestNextPage()
    XCTAssertTrue(paginator.results.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.results.values, [])
    XCTAssertFalse(paginator.results.isLoading)
    XCTAssertEqual(paginator.results, .error(ConcreteError()))
    XCTAssertNotNil(paginator.results.error)
  }

  func testPaginatorResults_mapValues_unloaded_remainsUnloaded() {
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results = .unloaded

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(mapped, .unloaded)
  }

  func testPaginatorResults_mapValues_someLoaded_transformsValues() {
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results =
      .someLoaded(values: [1, 2, 3], cursor: 42, total: 6, page: 1)

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(
      mapped,
      .someLoaded(values: [2, 4, 6], cursor: 42, total: 6, page: 1),
      "Should transform values while preserving cursor, total and page"
    )
  }

  func testPaginatorResults_mapValues_allLoaded_transformsValues() {
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results =
      .allLoaded(values: [1, 2, 3], page: 2)

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(
      mapped,
      .allLoaded(values: [2, 4, 6], page: 2),
      "Should transform values while preserving page"
    )
  }

  func testPaginatorResults_mapValues_empty_remainsEmpty() {
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results = .empty

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(mapped, .empty)
  }

  func testPaginatorResults_mapValues_error_remainsError() {
    let error = ConcreteError()
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results = .error(error)

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(mapped, .error(error))
  }

  func testPaginatorResults_mapValues_loading_transformsUnderlyingValues() {
    let underlying: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results =
      .someLoaded(values: [1, 2, 3], cursor: 42, total: 6, page: 1)
    let results: Paginator<TestEnvelope, Int, Int, ConcreteError, Void>.Results =
      .loading(previous: underlying)

    let mapped = results.mapValues { values in
      values.map { $0 * 2 }
    }

    XCTAssertEqual(
      mapped,
      .loading(previous: .someLoaded(values: [2, 4, 6], cursor: 42, total: 6, page: 1)),
      "Should transform values in the underlying state while preserving loading status"
    )
  }
}
