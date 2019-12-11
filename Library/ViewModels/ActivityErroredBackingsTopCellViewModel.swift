import KsApi
import ReactiveSwift

public protocol ActivityErroredBackingsTopCellInputs {
  func configure(with value: [GraphBacking])
}

public protocol ActivityErroredBackingsTopCellOutputs {
  var erroredBackings: Signal<[GraphBacking], Never> { get }
}

public protocol ActivityErroredBackingsTopCellViewModelType {
  var inputs: ActivityErroredBackingsTopCellInputs { get }
  var outputs: ActivityErroredBackingsTopCellOutputs { get }
}

public final class ActivityErroredBackingsTopCellViewModel: ActivityErroredBackingsTopCellViewModelType,
  ActivityErroredBackingsTopCellInputs, ActivityErroredBackingsTopCellOutputs {
  public init() {
    self.erroredBackings = self.backingsSignal
  }

  private let (backingsSignal, backingsObserver) = Signal<[GraphBacking], Never>.pipe()
  public func configure(with value: [GraphBacking]) {
    self.backingsObserver.send(value: value)
  }

  public let erroredBackings: Signal<[GraphBacking], Never>

  public var inputs: ActivityErroredBackingsTopCellInputs { return self }
  public var outputs: ActivityErroredBackingsTopCellOutputs { return self }
}
