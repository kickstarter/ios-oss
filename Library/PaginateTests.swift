// swiftlint:disable force_unwrapping
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
import XCTest
@testable import Library
import Prelude
import ReactiveSwift
import Result
@testable import ReactiveExtensions_TestHelpers

final class PaginateTests: TestCase {

  let (newRequest, newRequestObserver) = Signal<Int, NoError>.pipe()
  let (nextPage, nextPageObserver) = Signal<(), NoError>.pipe()
  let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in .init(value: [p]) }
  let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: c <= 2 ? [c] : []) }
  let valuesFromEnvelope: ([Int]) -> [Int] = id
  let cursorFromEnvelope: ([Int]) -> Int = { ($0.last ?? 0) + 1 }

  func testEmitsEmptyState_ClearOnNewRequest() {
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in .init(value: []) }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: []) }

    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false])

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false, true, false])
  }

  func testEmitsEmptyState_ClearOnNewRequest_With_Repeats() {
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in .init(value: []) }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: []) }

    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      skipRepeats: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false])

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[], [], []])
    loadingTest.assertValues([true, false, true, false])
  }

  func testEmitsEmptyState_DoNotClearOnNewRequest() {
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in .init(value: []) }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: []) }

    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false])

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false, true, false])
  }

  func testEmitsEmptyState_DoNotClearOnNewRequest_With_Repeats() {
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in .init(value: []) }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: []) }

    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[]])
    loadingTest.assertValues([true, false])

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[], []])
    loadingTest.assertValues([true, false, true, false])
  }

  func testPaginateFlow() {
    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    valuesTest.assertDidNotEmitValue("No values emit immediately.")
    loadingTest.assertDidNotEmitValue("No loading happens immediately.")

    // Start request for new set of values.
    self.newRequestObserver.send(value: 1)

    valuesTest.assertDidNotEmitValue("No values emit immediately.")
    loadingTest.assertValues([true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1]], "Values emit after waiting enough time for request to finish.")
    loadingTest.assertValues([true, false], "Loading stops.")

    // Request next page of values.
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "New page of values emit after waiting enough time.")
    loadingTest.assertValues([true, false, true, false], "Loading stops.")

    // Request next page of results (this page is empty since the last request exhausted the results.)
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1], [1, 2]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true, false, true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "No values emit since we exhausted all pages.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading stops.")

    // Try request for yet another page of values.
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1], [1, 2]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading does not start again.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "Still no values emit.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading did not start or stop again.")

    // Start over with a new request
    self.newRequestObserver.send(value: 0)

    valuesTest.assertValues([[1], [1, 2], []], "Values clear immediately.")
    loadingTest.assertValues([true, false, true, false, true, false, true], "Loading started.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [], [0]], "New page of values emits.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false], "Loading finishes.")

    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1], [1, 2], [], [0]], "New page of values emits.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false, true], "Loading finishes.")

    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [], [0], [0, 1]], "New page of values emits.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false, true, false],
                             "Loading finishes.")
  }

  func testPaginateFlow_With_Repeats() {
    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      skipRepeats: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    valuesTest.assertDidNotEmitValue("No values emit immediately.")
    loadingTest.assertDidNotEmitValue("No loading happens immediately.")

    // Start request for new set of values.
    self.newRequestObserver.send(value: 1)

    valuesTest.assertDidNotEmitValue("No values emit immediately.")
    loadingTest.assertValues([true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1]], "Values emit after waiting enough time for request to finish.")
    loadingTest.assertValues([true, false], "Loading stops.")

    // Request next page of values.
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "New page of values emit after waiting enough time.")
    loadingTest.assertValues([true, false, true, false], "Loading stops.")

    // Request next page of results (this page is empty since the last request exhausted the results.)
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1], [1, 2]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true, false, true], "Loading starts.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [1, 2]], "Repeated value emits.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading stops.")

    // Try request for yet another page of values.
    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1], [1, 2], [1, 2]], "No values emit immediately.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading does not start again.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [1, 2]], "No values emit.")
    loadingTest.assertValues([true, false, true, false, true, false], "Loading did not start or stop again.")

    // Start over with a new request
    self.newRequestObserver.send(value: 0)

    valuesTest.assertValues([[1], [1, 2], [1, 2], []], "Values clear immediately.")
    loadingTest.assertValues([true, false, true, false, true, false, true], "Loading started.")

    // Wait enough time for request to finish.
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [1, 2], [], [0]], "New page of values emits.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false], "Loading finishes.")

    self.newRequestObserver.send(value: 0)

    valuesTest.assertValues([[1], [1, 2], [1, 2], [], [0], []], "Values clear immediately.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false, true], "Loading starts.")

    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [1, 2], [], [0], [], [0]], "Repeated value emits.")
    loadingTest.assertValues([true, false, true, false, true, false, true, false, true, false],
                             "Loading starts.")
  }

  func testPaginate_DoesntClearOnNewRequest() {
    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    valuesTest.assertDidNotEmitValue()
    loadingTest.assertDidNotEmitValue()

    self.newRequestObserver.send(value: 1)

    valuesTest.assertDidNotEmitValue()
    loadingTest.assertValues([true])

    self.scheduler.advance()

    valuesTest.assertValues([[1]])
    loadingTest.assertValues([true, false])

    self.nextPageObserver.send(value: ())

    valuesTest.assertValues([[1]])
    loadingTest.assertValues([true, false, true])

    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]])
    loadingTest.assertValues([true, false, true, false])

    self.newRequestObserver.send(value: 1)

    valuesTest.assertValues([[1], [1, 2]])
    loadingTest.assertValues([true, false, true, false, true])

    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2], [1]])
    loadingTest.assertValues([true, false, true, false, true, false])
  }

  func testPaginate_InterleavingOfNextPage() {
    withEnvironment(apiDelayInterval: TestCase.interval) {
      let (values, loading, _) = paginate(
        requestFirstPageWith: newRequest,
        requestNextPageWhen: nextPage,
        clearOnNewRequest: true,
        valuesFromEnvelope: valuesFromEnvelope,
        cursorFromEnvelope: cursorFromEnvelope,
        requestFromParams: requestFromParams,
        requestFromCursor: requestFromCursor
      )

      let valuesTest = TestObserver<[Int], NoError>()
      values.observe(valuesTest.observer)
      let loadingTest = TestObserver<Bool, NoError>()
      loading.observe(loadingTest.observer)

      self.newRequestObserver.send(value: 1)
      self.scheduler.advance(by: TestCase.interval)

      valuesTest.assertValues([[1]], "Values emit after waiting enough time for request to finish.")
      loadingTest.assertValues([true, false], "Loading started and stopped.")

      self.nextPageObserver.send(value: ())
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1]], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true], "Still loading.")

      self.nextPageObserver.send(value: ())
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1]], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true, false, true], "Still loading.")

      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1], [1, 2]], "Next page of values emit.")
      loadingTest.assertValues([true, false, true, false, true, false], "Loading stops.")
    }
  }

  func testPaginate_ClearsOnNewRequest_InterleavingOfNewRequestAndNextPage() {
    withEnvironment(apiDelayInterval: TestCase.interval) {
      let (values, loading, _) = paginate(
        requestFirstPageWith: newRequest,
        requestNextPageWhen: nextPage,
        clearOnNewRequest: true,
        valuesFromEnvelope: valuesFromEnvelope,
        cursorFromEnvelope: cursorFromEnvelope,
        requestFromParams: requestFromParams,
        requestFromCursor: requestFromCursor
      )

      let valuesTest = TestObserver<[Int], NoError>()
      values.observe(valuesTest.observer)
      let loadingTest = TestObserver<Bool, NoError>()
      loading.observe(loadingTest.observer)

      // Request the first page and wait enough time for request to finish.
      self.newRequestObserver.send(value: 1)
      self.scheduler.advance(by: TestCase.interval)

      valuesTest.assertValues([[1]], "Values emit after waiting enough time for request to finish.")
      loadingTest.assertValues([true, false], "Loading started and stopped.")

      // Request the next page and wait only a little bit of time.
      self.nextPageObserver.send(value: ())
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1]], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true], "Still loading.")

      // Make a new request for the first page.
      self.newRequestObserver.send(value: 0)

      valuesTest.assertValues([[1], []], "Values clear immediately.")
      loadingTest.assertValues([true, false, true, false, true], "Still loading.")

      // Wait a little bit of time, not enough for request to finish.
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1], []], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true, false, true], "Still loading.")

      // Wait enough time for request to finish.
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1], [], [0]], "Next page of values emit.")
      loadingTest.assertValues([true, false, true, false, true, false], "Loading stops.")
    }
  }

  func testPaginate_DoesNotClearOnNewRequest_InterleavingOfNewRequestAndNextPage() {
    withEnvironment(apiDelayInterval: TestCase.interval) {
      let (values, loading, _) = paginate(
        requestFirstPageWith: newRequest,
        requestNextPageWhen: nextPage,
        clearOnNewRequest: false,
        valuesFromEnvelope: valuesFromEnvelope,
        cursorFromEnvelope: cursorFromEnvelope,
        requestFromParams: requestFromParams,
        requestFromCursor: requestFromCursor
      )

      let valuesTest = TestObserver<[Int], NoError>()
      values.observe(valuesTest.observer)
      let loadingTest = TestObserver<Bool, NoError>()
      loading.observe(loadingTest.observer)

      // Request the first page and wait enough time for request to finish.
      self.newRequestObserver.send(value: 1)
      self.scheduler.advance(by: TestCase.interval)

      valuesTest.assertValues([[1]], "Values emit after waiting enough time for request to finish.")
      loadingTest.assertValues([true, false], "Loading started and stopped.")

      // Request the next page and wait only a little bit of time.
      self.nextPageObserver.send(value: ())
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1]], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true], "Still loading.")

      // Make a new request for the first page.
      self.newRequestObserver.send(value: 0)

      valuesTest.assertValues([[1]], "Does not clear immediately.")
      loadingTest.assertValues([true, false, true, false, true], "Still loading.")

      // Wait a little bit of time, not enough for request to finish.
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1]], "Values don't emit yet.")
      loadingTest.assertValues([true, false, true, false, true], "Still loading.")

      // Wait enough time for request to finish.
      self.scheduler.advance(by: TestCase.interval.halved())

      valuesTest.assertValues([[1], [0]], "Next page of values emit.")
      loadingTest.assertValues([true, false, true, false, true, false], "Loading stops.")
    }
  }

  // Tests the flow:
  //   * Load first page of values
  //   * Try loading a different first page of values but the result is empty
  // Confirms that an empty list of values is emitted.
  func testEmptyState_AfterResultSetWasObtained() {
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = {
      p in p == 2 ? .init(value: []) : .init(value: [1, 2])
    }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in .init(value: []) }

    let (values, _, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)

    // A first page request that does have values
    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[1, 2]], "Some values are emitted.")

    // A first page request that does not have any values
    self.newRequestObserver.send(value: 2)
    self.scheduler.advance()

    valuesTest.assertValues([[1, 2], []], "An empty set of values is emitted.")
  }

  // Tests the flow
  //   * Load first page of values
  //   * Load second page of values
  //   * Load third page of values but an empty set is returned
  //   * Try loading a fourth page of values
  // Confirms that no additional request is made for the fourth page.
  func testAdditionalPagesAreNotRequestedWhenNoMoreValues() {
    var numberOfRequests = 0
    let requestFromParams: (Int) -> SignalProducer<[Int], NoError> = { p in
      numberOfRequests += 1
      return .init(value: [p])
    }
    let requestFromCursor: (Int) -> SignalProducer<[Int], NoError> = { c in
      numberOfRequests += 1
      return .init(value: c <= 2 ? [c] : [])
    }

    let (values, loading, _) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let valuesTest = TestObserver<[Int], NoError>()
    values.observe(valuesTest.observer)
    let loadingTest = TestObserver<Bool, NoError>()
    loading.observe(loadingTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    valuesTest.assertValues([[1]], "First page of values emitted.")
    XCTAssertEqual(1, numberOfRequests, "One request is made.")

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "Second page of values emitted.")
    XCTAssertEqual(2, numberOfRequests, "Another request is made.")

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "Third page was empty so no new values are emitted.")
    XCTAssertEqual(3, numberOfRequests, "One last request is made.")

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    valuesTest.assertValues([[1], [1, 2]], "Still no values emitted.")
    XCTAssertEqual(3, numberOfRequests, "No additional requests made.")
  }

  func testPageCount_WhenNotClearingOnFirstRequest() {
    let (_, _, pageCountLoaded) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: false,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let pageCountLoadedTest = TestObserver<Int, NoError>()
    pageCountLoaded.observe(pageCountLoadedTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3])

    self.newRequestObserver.send(value: 0)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3, 4])

    self.newRequestObserver.send(value: 0)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3, 4, 1])
  }

  func testPageCount_WhenClearingOnFirstRequest() {
    let (_, _, pageCountLoaded) = paginate(
      requestFirstPageWith: newRequest,
      requestNextPageWhen: nextPage,
      clearOnNewRequest: true,
      valuesFromEnvelope: valuesFromEnvelope,
      cursorFromEnvelope: cursorFromEnvelope,
      requestFromParams: requestFromParams,
      requestFromCursor: requestFromCursor
    )

    let pageCountLoadedTest = TestObserver<Int, NoError>()
    pageCountLoaded.observe(pageCountLoadedTest.observer)

    self.newRequestObserver.send(value: 1)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3])

    self.newRequestObserver.send(value: 0)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3])

    self.nextPageObserver.send(value: ())
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3, 4])

    self.newRequestObserver.send(value: 0)
    self.scheduler.advance()

    pageCountLoadedTest.assertValues([1, 2, 3, 1, 2, 3, 4, 1])
  }
}
