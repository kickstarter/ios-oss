import Foundation
import ReactiveSwift

public protocol PledgeContinueCellViewModelOutputs {
  var goToLoginSignup: Signal<Void, Never> { get }
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
    self.goToLoginSignup = self.continueButtonTappedProperty.signal
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  public let goToLoginSignup: Signal<Void, Never>

  public var inputs: PledgeContinueCellViewModelInputs { return self }
  public var outputs: PledgeContinueCellViewModelOutputs { return self }
}
