public protocol SimpleViewModelOutputs {
  typealias Model
  var model: Model { get }
}

/// Represents the simplest form of a view model: one that wraps a model and exposes a single output
/// for access to that model.
public final class SimpleViewModel <M> : ViewModelType, SimpleViewModelOutputs {
  public typealias Model = M
  public let model: M

  public init(model: M) {
    self.model = model
  }
}
