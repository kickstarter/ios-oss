import KsApi
import ReactiveSwift

public protocol ActivityErroredBackingsCellInputs {
  func configure(with value: [ProjectAndBackingEnvelope])
}

public protocol ActivityErroredBackingsCellOutputs {
  var erroredBackings: Signal<[ProjectAndBackingEnvelope], Never> { get }
}

public protocol ActivityErroredBackingsCellViewModelType {
  var inputs: ActivityErroredBackingsCellInputs { get }
  var outputs: ActivityErroredBackingsCellOutputs { get }
}

public final class ActivityErroredBackingsCellViewModel: ActivityErroredBackingsCellViewModelType,
  ActivityErroredBackingsCellInputs, ActivityErroredBackingsCellOutputs {
  public init() {
    self.erroredBackings = self.backingsSignal
  }

  private let (backingsSignal, backingsObserver) = Signal<[ProjectAndBackingEnvelope], Never>.pipe()
  public func configure(with value: [ProjectAndBackingEnvelope]) {
    self.backingsObserver.send(value: value)
  }

  public let erroredBackings: Signal<[ProjectAndBackingEnvelope], Never>

  public var inputs: ActivityErroredBackingsCellInputs { return self }
  public var outputs: ActivityErroredBackingsCellOutputs { return self }
}
