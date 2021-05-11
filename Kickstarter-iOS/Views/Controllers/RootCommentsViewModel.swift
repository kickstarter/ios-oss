import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol RootCommentsViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()
}

public protocol RootCommentsViewModelOutputs {}

public protocol RootCommentsViewModelType {
  var inputs: RootCommentsViewModelInputs { get }
  var outputs: RootCommentsViewModelOutputs { get }
}

public final class RootCommentsViewModel: RootCommentsViewModelType, RootCommentsViewModelInputs,
  RootCommentsViewModelOutputs {
  public init() {}

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: RootCommentsViewModelInputs { return self }
  public var outputs: RootCommentsViewModelOutputs { return self }
}
