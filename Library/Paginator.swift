import Combine
import Foundation

/**
 Used to coordinate the process of paginating through values. This class is specific to the type of pagination
 in which a page's results contains a cursor that can be used to request the next page of values.

 This class is designed to work with SwiftUI/Combine. For an example, see `PaginationExampleView.swift`.

 This class is generic over the following types:

 * `Value`:         The type of value that is being paginated, i.e. a single row, not the array of rows. The
                    value must be equatable.
 * `Envelope`:      The type of response we get from fetching a new page of values.
 * `SomeError`: The type of error we might get from fetching a new page of values.
 * `Cursor`:        The type of value that can be extracted from `Envelope` to request the next page of
                    values.
 * `RequestParams`: The type that allows us to make a request for values without a cursor.

 - parameter valuesFromEnvelope:   A function to get an array of values from the results envelope.
 - parameter cursorFromEnvelope:   A function to get the cursor for the next page from a results envelope.
 - parameter requestFromParams:    A function to get a request for values from a params value.
 - parameter requestFromCursor:    A function to get a request for values from a cursor value.

  You can observe the results of `values`, `isLoading`, `error` and `state` to access the loaded data.

 */

public class Paginator<Envelope, Value: Equatable, Cursor, SomeError: Error, RequestParams> {
  public enum Results: Equatable {
    case unloaded
    case someLoaded
    case allLoaded
    case empty
    case error
  }

  @Published public var values: [Value]
  @Published public var isLoading: Bool
  @Published public var error: SomeError?
  @Published public var state: Results

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
    self.values = []
    self.isLoading = false
    self.error = nil
    self.state = .unloaded

    self.valuesFromEnvelope = valuesFromEnvelope
    self.cursorFromEnvelope = cursorFromEnvelope
    self.requestFromParams = requestFromParams
    self.requestFromCursor = requestFromCursor
  }

  func handleRequest(_ request: AnyPublisher<Envelope, SomeError>) {
    request
      .receive(on: RunLoop.main)
      .catch { [weak self] error -> AnyPublisher<Envelope, SomeError> in
        self?.error = error
        self?.state = .error
        return Empty<Envelope, SomeError>().eraseToAnyPublisher()
      }
      .assertNoFailure()
      .handleEvents(receiveCompletion: { [weak self] _ in
        self?.isLoading = false
      }, receiveCancel: { [weak self] in
        self?.isLoading = false
      })
      .sink(receiveValue: { [weak self] envelope in
        guard let self else { return }

        let newValues = self.valuesFromEnvelope(envelope)
        self.values.append(contentsOf: newValues)

        let cursor = self.cursorFromEnvelope(envelope)
        self.lastCursor = cursor

        if self.values.count == 0 {
          self.state = .empty
        } else if cursor == nil || newValues.count == 0 {
          self.state = .allLoaded
        } else {
          self.state = .someLoaded
        }
      })
      .store(in: &self.cancellables)
  }

  public func requestFirstPage(withParams params: RequestParams) {
    self.cancel()

    self.values = []
    self.isLoading = true
    self.error = nil

    let request = self.requestFromParams(params)
    self.handleRequest(request)
  }

  public func requestNextPage() {
    if self.isLoading {
      return
    }

    if self.state != .someLoaded {
      return
    }

    self.isLoading = true
    guard let cursor = self.lastCursor else {
      assert(false, "Requested next page, but there is no cursor.")
      return
    }

    let request = self.requestFromCursor(cursor)
    self.handleRequest(request)
  }

  public func cancel() {
    self.cancellables.forEach { cancellable in
      cancellable.cancel()
    }
  }
}
