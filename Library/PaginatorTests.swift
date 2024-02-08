import Combine
@testable import Library
import XCTest

struct TestEnvelope {
  let values: [Int]
  let cursor: Int?

  var publisher: AnyPublisher<TestEnvelope, ConcreteError> {
    return Just(self).setFailureType(to: ConcreteError.self).eraseToAnyPublisher()
  }
}

struct ConcreteError: Error {}

final class PaginatorTests: XCTestCase {
  let valuesFromEnvelope: (TestEnvelope) -> [Int] = { $0.values }
  let cursorFromEnvelope: (TestEnvelope) -> Int? = { $0.cursor }

  func waitTinyInterval() {
    _ = XCTWaiter.wait(for: [expectation(description: "Wait a tiny interval of time.")], timeout: 0.05)
  }

  func testPaginator_initialState_isUnloaded() {
    let paginator = Paginator<TestEnvelope, Int, Int?, ConcreteError, Int>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    XCTAssertEqual(paginator.state, .unloaded)
    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [])
  }

  func testPaginator_requestFirstPage_loadsFirstPage() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)
    XCTAssertEqual(paginator.values, [], "Values should not have loaded yet")

    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [1, 2, 3])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .allLoaded)
  }

  func testPaginator_requestFirstPage_noResults_isEmpty() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)
    XCTAssertEqual(paginator.values, [], "Values should not have loaded yet")

    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .empty)
  }

  func testPaginator_requestNextPage_hasCursor_loadsNextPage() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: 2).publisher
        } else if cursor == 2 {
          return TestEnvelope(values: [7, 8, 9], cursor: nil).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.state, .someLoaded)
    XCTAssertEqual(paginator.values, [1, 2, 3])

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .someLoaded)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .allLoaded)
  }

  func testPaginator_requestNextPage_returnsNoCursor_finishes() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: nil).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.state, .someLoaded)
    XCTAssertEqual(paginator.values, [1, 2, 3])

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .allLoaded)

    paginator.requestNextPage()
    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.state, .allLoaded)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6])
  }

  func testPaginator_requestNextPage_returnsNoResults_finishes() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { cursor in
        if cursor == 1 {
          return TestEnvelope(values: [4, 5, 6], cursor: 2).publisher
        } else if cursor == 2 {
          return TestEnvelope(values: [], cursor: 3).publisher
        } else {
          XCTFail()
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
      }
    )

    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(paginator.state, .someLoaded)
    XCTAssertEqual(paginator.values, [1, 2, 3])

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)
    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6])
    XCTAssertNil(paginator.error)
    XCTAssertEqual(paginator.state, .someLoaded)

    paginator.requestNextPage()
    self.waitTinyInterval()

    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.state, .allLoaded)
    XCTAssertEqual(paginator.values, [1, 2, 3, 4, 5, 6])
  }

  func testPaginator_cancel_cancelsPendingRequests() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: nil).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)

    // Don't wait the time interval for the request to complete
    paginator.cancel()
    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.values, [], "Cancel should have kept the new values from loading")

    // Now wait, and double-check
    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [], "Cancel should have kept the new values from loading")
  }

  func testPaginator_requestNextPage_whileLoading_doesNothing() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [4, 5, 6], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)

    paginator.requestNextPage()

    self.waitTinyInterval()
    XCTAssertEqual(
      paginator.values,
      [1, 2, 3],
      "Second page should not have loaded while first page was still loading"
    )
  }

  func testPaginator_requestFirstPage_whileLoading_cancelsPreviousRequest() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { _ in TestEnvelope(values: [4, 5, 6], cursor: nil).publisher }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [1, 2, 3])
    XCTAssertFalse(paginator.isLoading)

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)

    // Don't let it load, request the first page again
    paginator.requestFirstPage(withParams: ())

    self.waitTinyInterval()

    XCTAssertEqual(
      paginator.values,
      [1, 2, 3],
      "Second page should not have loaded, because it should have been canceled by reloading the first page"
    )
  }

  func testPaginator_requestFirstPage_withError_setsError() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in
        Fail(outputType: TestEnvelope.self, failure: ConcreteError()).eraseToAnyPublisher()
      },
      requestFromCursor: { _ in Empty().eraseToAnyPublisher() }
    )

    paginator.requestFirstPage(withParams: ())
    XCTAssertTrue(paginator.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [])
    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.state, .error)
    XCTAssertNotNil(paginator.error)
  }

  func testPaginator_requestNextPage_withError_setsError() {
    let paginator = Paginator<TestEnvelope, Int, Int, ConcreteError, Void>(
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: { _ in TestEnvelope(values: [1, 2, 3], cursor: 1).publisher },
      requestFromCursor: { _ in
        Fail(outputType: TestEnvelope.self, failure: ConcreteError()).eraseToAnyPublisher()
      }
    )

    paginator.requestFirstPage(withParams: ())
    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [1, 2, 3])

    paginator.requestNextPage()
    XCTAssertTrue(paginator.isLoading)

    self.waitTinyInterval()
    XCTAssertEqual(paginator.values, [1, 2, 3])
    XCTAssertFalse(paginator.isLoading)
    XCTAssertEqual(paginator.state, .error)
    XCTAssertNotNil(paginator.error)
  }
}
