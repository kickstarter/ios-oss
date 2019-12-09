import KsApi
import ReactiveSwift

public protocol ErroredBackingCellViewModelInputs {
  func configure(with value: GraphBacking)
}

public protocol ErroredBackingCellViewModelOutputs {
  var projectName: Signal<String, Never> { get }
}

public protocol ErroredBackingCellViewModelType {
  var inputs: ErroredBackingCellViewModelInputs { get }
  var outputs: ErroredBackingCellViewModelOutputs { get }
}

public final class ErroredBackingCellViewModel: ErroredBackingCellViewModelType,
ErroredBackingCellViewModelInputs, ErroredBackingCellViewModelOutputs {

  public init() {
    self.projectName = self.backingSignal
      .map(\.project?.name)
      .skipNil()
  }

  private let (backingSignal, backingObserver) = Signal<GraphBacking, Never>.pipe()
  public func configure(with value: GraphBacking) {
    self.backingObserver.send(value: value)
  }

  public let projectName: Signal<String, Never>

  public var inputs: ErroredBackingCellViewModelInputs { return self }
  public var outputs: ErroredBackingCellViewModelOutputs { return self }
}
