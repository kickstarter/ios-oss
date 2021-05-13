import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentsViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentsViewModelOutputs {}

public protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

public final class CommentsViewModel: CommentsViewModelType,
  CommentsViewModelInputs,
  CommentsViewModelOutputs {
  public init() {
    // FIXME: Configure this VM with a project in order to feed the slug in here to fetch comments
    // Call this again with a cursor to paginate.
    self.viewDidLoadProperty.signal.switchMap { _ in
      AppEnvironment.current.apiService
        .fetchComments(query: comments(withProjectSlug: "bring-back-weekly-world-news"))
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }
    .observeValues { print($0) }
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
