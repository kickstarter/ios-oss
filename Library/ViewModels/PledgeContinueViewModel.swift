import Foundation
import ReactiveSwift

public protocol PledgeContinueViewModelOutputs {
  var goToLoginSignup: Signal<LoginIntent, Never> { get }
}

public protocol PledgeContinueViewModelInputs {
  func continueButtonTapped()
}

public protocol PledgeContinueViewModelType {
  var inputs: PledgeContinueViewModelInputs { get }
  var outputs: PledgeContinueViewModelOutputs { get }
}

public final class PledgeContinueViewModel: PledgeContinueViewModelType,
  PledgeContinueViewModelInputs, PledgeContinueViewModelOutputs {
  public init() {
    self.goToLoginSignup = self.continueButtonTappedProperty.signal
      .map { _ in LoginIntent.backProject }
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  public let goToLoginSignup: Signal<LoginIntent, Never>

  public var inputs: PledgeContinueViewModelInputs { return self }
  public var outputs: PledgeContinueViewModelOutputs { return self }
}
