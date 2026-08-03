import GraphAPI
import KsApi
import ReactiveSwift

public protocol FetchFlaggingOptionsUseCaseType {
  var inputs: FetchFlaggingOptionsUseCaseInputs { get }
  var outputs: FetchFlaggingOptionsUseCaseDataOutputs { get }
}

public protocol FetchFlaggingOptionsUseCaseInputs {}

public protocol FetchFlaggingOptionsUseCaseDataOutputs {
  /// Emits the mapped list of report items when the query succeeds.
  var flaggingOptions: Signal<[ReportProjectInfoListItem], Never> { get }

  /// Emits `true` while a fetch is in flight, `false` once it completes.
  var isLoading: Signal<Bool, Never> { get }
}

/// A reusable use case for fetching flagging (report) options for any content type
/// (projects, comments, backings, etc.) via the `FlaggingOptionsQuery`.
public final class FetchFlaggingOptionsUseCase: FetchFlaggingOptionsUseCaseType,
  FetchFlaggingOptionsUseCaseInputs,
  FetchFlaggingOptionsUseCaseDataOutputs {
  /// - Parameters:
  ///   - contentType: The kind of content whose flagging options should be fetched (e.g. `.project`, `comment`).
  ///   - initialSignal: A signal whose first event triggers the fetch.
  public init(contentType: GraphAPI.FlaggingContent, initialSignal: Signal<Void, Never>) {
    /// Emit an empty array immediately so the view has a valid initial value.
    let emptyOnTrigger: Signal<[ReportProjectInfoListItem], Never> = initialSignal.mapConst([])

    /// Start loading as soon as the trigger fires.
    let loadingStarted: Signal<Bool, Never> = initialSignal.mapConst(true)

    /// Materializing errors so they never terminate the signal.
    let response = initialSignal
      .switchMap { _ in
        AppEnvironment.current.apiService
          .fetchFlaggingOptions(contentType: contentType)
          .materialize()
      }

    /// Map successful responses to list items.
    let loadedItems: Signal<[ReportProjectInfoListItem], Never> = response
      .values()
      .map { ReportProjectInfoListItem.items(from: $0) }

    /// Stop loading on a value or error, but not on the completed event.
    let loadingFinished: Signal<Bool, Never> = Signal.merge(
      response.values().mapConst(false),
      response.errors().mapConst(false)
    )

    self.flaggingOptions = Signal.merge(emptyOnTrigger, loadedItems)
    self.isLoading = Signal.merge(loadingStarted, loadingFinished)
  }

  // MARK: - Outputs

  public let flaggingOptions: Signal<[ReportProjectInfoListItem], Never>
  public let isLoading: Signal<Bool, Never>

  public var inputs: FetchFlaggingOptionsUseCaseInputs { return self }
  public var outputs: FetchFlaggingOptionsUseCaseDataOutputs { return self }
}
