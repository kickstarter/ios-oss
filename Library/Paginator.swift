import Combine
import Foundation

/**
 Used to coordinate the process of paginating through values. This class is specific to the type of pagination
 in which a page's results contains a cursor that can be used to request the next page of values.

 This class is designed to work with SwiftUI/Combine. For an example, see `PaginationExampleView.swift`.

 This class is generic over the following types:

 * `Envelope`:      The type of response we get from fetching a new page of values.
 * `Value`:         The type of value that is being paginated, i.e. a single row, not the array of rows. The
                    value must be equatable.
 * `Cursor`:        The type of value that can be extracted from `Envelope` to request the next page of
                    values.
 * `SomeError`: The type of error we might get from fetching a new page of values.
 * `RequestParams`: The type that allows us to make a request for values without a cursor.

 - parameter valuesFromEnvelope:   A function to get an array of values from the results envelope.
 - parameter cursorFromEnvelope:   A function to get the cursor for the next page from a results envelope.
 - parameter requestFromParams:    A function to get a request for values from a params value.
 - parameter requestFromCursor:    A function to get a request for values from a cursor value.

  You can observe the results of `values`, `isLoading`, `error` and `results` to access the loaded data.

 */

public class Paginator<Envelope, Value: Equatable, Cursor: Equatable, SomeError: Error, RequestParams> {
  public enum Results: Equatable {
    public static func == (
      lhs: Paginator<Envelope, Value, Cursor, SomeError, RequestParams>.Results,
      rhs: Paginator<Envelope, Value, Cursor, SomeError, RequestParams>.Results
    ) -> Bool {
      switch (lhs, rhs) {
      case (.unloaded, .unloaded):
        return true
      case let (.someLoaded(lhsValues, lhsCursor), .someLoaded(rhsValues, rhsCursor)):
        return lhsValues == rhsValues && lhsCursor == rhsCursor
      case let (.allLoaded(lhsValues), .allLoaded(rhsValues)):
        return lhsValues == rhsValues
      case (.empty, .empty):
        return true
      case let (.error(lhsError), .error(rhsError)):
        return lhsError.localizedDescription == rhsError.localizedDescription
      case let (.loading(lhsPrevious), .loading(rhsPrevious)):
        return lhsPrevious == rhsPrevious
      case (.unloaded, _),
           (.someLoaded, _),
           (.allLoaded, _),
           (.empty, _),
           (.error, _),
           (.loading, _):
        return false
      }
    }

    case unloaded
    case someLoaded(values: [Value], cursor: Cursor)
    case allLoaded(values: [Value])
    case empty
    case error(SomeError)
    indirect case loading(previous: Results)

    public var values: [Value] {
      switch self {
      case .unloaded:
        []
      case let .loading(previous):
        previous.values
      case let .someLoaded(values, _):
        values
      case let .allLoaded(values):
        values
      case .empty:
        []
      case .error:
        []
      }
    }

    public var cursor: Cursor? {
      guard case let .someLoaded(_, cursor) = self else {
        return nil
      }
      return cursor
    }

    public var isLoading: Bool {
      guard case .loading = self else { return false }
      return true
    }

    public var error: SomeError? {
      guard case let .error(error) = self else { return nil }
      return error
    }

    public var canLoadMore: Bool {
      switch self {
      case .someLoaded, .unloaded:
        true
      case .empty, .error, .allLoaded, .loading:
        false
      }
    }
  }

  @Published public var results: Results

  private var valuesFromEnvelope: (Envelope) -> [Value]
  private var cursorFromEnvelope: (Envelope) -> Cursor?
  private var requestFromParams: (RequestParams) -> AnyPublisher<Envelope, SomeError>
  private var requestFromCursor: (Cursor) -> AnyPublisher<Envelope, SomeError>
  private var cancellables = Set<AnyCancellable>()

  private var lastCursor: Cursor?

  public init(
    valuesFromEnvelope: @escaping ((Envelope) -> [Value]),
    cursorFromEnvelope: @escaping ((Envelope) -> Cursor?),
    requestFromParams: @escaping ((RequestParams) -> AnyPublisher<Envelope, SomeError>),
    requestFromCursor: @escaping ((Cursor) -> AnyPublisher<Envelope, SomeError>)
  ) {
    self.results = .unloaded

    self.valuesFromEnvelope = valuesFromEnvelope
    self.cursorFromEnvelope = cursorFromEnvelope
    self.requestFromParams = requestFromParams
    self.requestFromCursor = requestFromCursor
  }

  func handleRequest(_ request: AnyPublisher<Envelope, SomeError>, shouldClear: Bool) {
    request
      .combineLatest(self.$results.first().setFailureType(to: SomeError.self))
      .map { [weak self] envelope, previousResults -> Results in
        guard let self else {
          fatalError()
        }

        let newValues = self.valuesFromEnvelope(envelope)
        let nextCursor = self.cursorFromEnvelope(envelope)
        var allValues = shouldClear ? [] : previousResults.values
        allValues.append(contentsOf: newValues)

        let results: Results = if allValues.count == 0 {
          .empty
        } else if let nextCursor, !newValues.isEmpty {
          .someLoaded(values: allValues, cursor: nextCursor)
        } else {
          .allLoaded(values: allValues)
        }
        return results
      }
      .catch { error -> AnyPublisher<Results, Never> in
        Just(.error(error)).eraseToAnyPublisher()
      }
      .prepend(.loading(previous: self.results))
      .sink(receiveValue: { results in
        self.results = results
      })
      .store(in: &self.cancellables)
  }

  public func requestFirstPage(withParams params: RequestParams) {
    self.cancel()

    let request = self.requestFromParams(params)
    self.handleRequest(request, shouldClear: true)
  }

  public func requestNextPage() {
    guard !self.results.isLoading, let cursor = self.results.cursor else {
      return
    }

    let request = self.requestFromCursor(cursor)
    self.handleRequest(request, shouldClear: false)
  }

  public func cancel() {
    if case let .loading(previous) = self.results {
      self.results = previous
    }

    self.cancellables.forEach { cancellable in
      cancellable.cancel()
    }
  }
}

extension Paginator where RequestParams == Void {
  public func requestFirstPage() {
    self.requestFirstPage(withParams: ())
  }
}
