import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol RootCommentsViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()
}

public protocol RootCommentsViewModelOutputs {
  /// Delete this when beginning implementation
  var viewDidLoadTestOutput: Signal<Bool, Never> { get }
}

public protocol RootCommentsViewModelType {
  var inputs: RootCommentsViewModelInputs { get }
  var outputs: RootCommentsViewModelOutputs { get }
}

public final class RootCommentsViewModel: RootCommentsViewModelType, RootCommentsViewModelInputs,
  RootCommentsViewModelOutputs {
  public init() {
    /// Skeleton implementation for now. Remove when ready to continue development.
    self.viewDidLoadTestOutput = self.viewDidLoadProperty.signal.mapConst(true)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let viewDidLoadTestOutput: Signal<Bool, Never>

  public var inputs: RootCommentsViewModelInputs { return self }
  public var outputs: RootCommentsViewModelOutputs { return self }
}
