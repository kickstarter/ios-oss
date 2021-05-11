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
  public init() {}

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
