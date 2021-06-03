import KsApi
import ReactiveSwift

public protocol CommentTableViewFooterViewModelInputs {
  func configure(with value: Bool)
}

public protocol CommentTableViewFooterViewModelOutputs {
  var shouldStartLoaderIndicator: Signal<Bool, Never> { get }
}

public protocol CommentTableViewFooterViewModelType {
  var inputs: CommentTableViewFooterViewModelInputs { get }
  var outputs: CommentTableViewFooterViewModelOutputs { get }
}

public final class CommentTableViewFooterViewModel: CommentTableViewFooterViewModelType,
  CommentTableViewFooterViewModelInputs, CommentTableViewFooterViewModelOutputs {
  public init() {
    self.shouldStartLoaderIndicator = self.loadingIndicatorSignal
  }

  fileprivate let (loadingIndicatorSignal, observer) = Signal<Bool, Never>.pipe()
  public func configure(with value: Bool) {
    self.observer.send(value: value)
  }

  public let shouldStartLoaderIndicator: Signal<Bool, Never>

  public var inputs: CommentTableViewFooterViewModelInputs { return self }
  public var outputs: CommentTableViewFooterViewModelOutputs { return self }
}
