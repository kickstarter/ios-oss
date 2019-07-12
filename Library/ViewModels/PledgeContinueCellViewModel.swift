import Foundation
import ReactiveSwift

public protocol PledgeContinueCellViewModelOutputs {
  var notifyDelegateContinueButtonTapped: Signal<Void, Never> { get }
}

public protocol PledgeContinueCellViewModelInputs {
  func continueButtonTapped()
}

public protocol PledgeContinueCellViewModelType {
  var inputs: PledgeContinueCellViewModelInputs { get }
  var outputs: PledgeContinueCellViewModelOutputs { get }
}

public final class PledgeContinueCellViewModel: PledgeContinueCellViewModelType,
  PledgeContinueCellViewModelInputs, PledgeContinueCellViewModelOutputs {
  public init() {
    self.notifyDelegateContinueButtonTapped = self.continueButtonTappedProperty.signal
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  public let notifyDelegateContinueButtonTapped: Signal<Void, Never>

  public var inputs: PledgeContinueCellViewModelInputs { return self }
  public var outputs: PledgeContinueCellViewModelOutputs { return self }
}
