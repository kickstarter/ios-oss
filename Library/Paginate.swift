import ReactiveSwift
import Result
import Prelude
import ReactiveExtensions

/**
 Returns signals that can be used to coordinate the process of paginating through values. This function is
 specific to the type of pagination in which a page's results contains a cursor that can be used to request
 the next page of values.

 This function is generic over the following types:

 * `Value`:         The type of value that is being paginated, i.e. a single row, not the array of rows. The
                    value must be equatable.
 * `Envelope`:      The type of response we get from fetching a new page of values.
 * `ErrorEnvelope`: The type of error we might get from fetching a new page of values.
 * `Cursor`:        The type of value that can be extracted from `Envelope` to request the next page of
                    values.
 * `RequestParams`: The type that allows us to make a request for values without a cursor.

 - parameter requestFirstPageWith: A signal that emits request params when a first page request should be
                                   made.
 - parameter requestNextPageWhen:  A signal that emits whenever next page of values should be fetched.
 - parameter clearOnNewRequest:    A boolean that determines if results should be cleared when a new request
                                   is made, i.e. an empty array will immediately be emitted.
 - parameter skipRepeats:          A boolean that determines if results can be repeated.
 - parameter valuesFromEnvelope:   A function to get an array of values from the results envelope.
 - parameter cursorFromEnvelope:   A function to get the cursor for the next page from a results envelope.
 - parameter requestFromParams:    A function to get a request for values from a params value.
 - parameter requestFromCursor:    A function to get a request for values from a cursor value.
 - parameter concater:             An optional function that concats a page of values to the current array of
                                   values. By default this simply concatenates the arrays, but you might want
                                   to do something more specific, such as concatenating only distinct values.

 - returns: A tuple of signals, (paginatedValues, isLoading, pageCount). The `paginatedValues` signal will
            emit a full set of values when a new page has loaded. The `isLoading` signal will emit `true`
            while a page of values is loading, and then `false` when it has terminated (either by completion
            or error). Finally, `pageCount` emits the number of the page that loaded, starting at 1.
 */
public func paginate <Cursor, Value: Equatable, Envelope, ErrorEnvelope, RequestParams> (
  requestFirstPageWith requestFirstPage: Signal<RequestParams, NoError>,
  requestNextPageWhen  requestNextPage: Signal<(), NoError>,
                       clearOnNewRequest: Bool,
                       skipRepeats: Bool = true,
                       valuesFromEnvelope: @escaping ((Envelope) -> [Value]),
                       cursorFromEnvelope: @escaping ((Envelope) -> Cursor),
                       requestFromParams: @escaping ((RequestParams) -> SignalProducer<Envelope, ErrorEnvelope>),
                       requestFromCursor: @escaping ((Cursor) -> SignalProducer<Envelope, ErrorEnvelope>),
                       concater: @escaping (([Value], [Value]) -> [Value]) = (+))
  ->
  (paginatedValues: Signal<[Value], NoError>,
   isLoading: Signal<Bool, NoError>,
   pageCount: Signal<Int, NoError>) {

    // FIXME

//    let cursor = MutableProperty<Cursor?>(nil)
//    let isLoading = MutableProperty<Bool>(false)
//
//    // Emits the last cursor when nextPage emits
//    let cursorOnNextPage = cursor.producer.skipNil().sample(on: requestNextPage)
//
//    let paginatedValues = requestFirstPage
//      .switchMap { requestParams in
//
//        cursorOnNextPage.map(Either<RequestParams, Cursor>.right)
//          .prefix(value: Either<RequestParams, Cursor>.left(requestParams))
//          .switchMap { paramsOrCursor in
//
//            paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
//              .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
//              .on(
//                started: { [weak isLoading] _ in
//                  isLoading?.value = true
//                },
//                terminated: { [weak isLoading] _ in
//                  isLoading?.value = false
//                },
//                next: { [weak cursor] env in
//                  cursor?.value = cursorFromEnvelope(env)
//              })
//              .map(valuesFromEnvelope)
//              .demoteErrors()
//          }
//          .takeUntil { $0.isEmpty }
//          .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
//          .scan([], concater)
//      }
//      .skip(clearOnNewRequest ? 1 : 0)
//
//    let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
//      .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
//      .filter { $0 > 0 }
//
//    return (
//      (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
//      isLoading.signal,
//      pageCount
//    )

    return (.empty, .empty, .empty)
}
