import Foundation
import KsApi
import ReactiveSwift

public protocol PledgeDisclaimerViewModelOutputs {
  var notifyDelegatePresentTrustAndSafety: Signal<Void, Never> { get }
}

public protocol PledgeDisclaimerViewModelInputs {
  func learnMoreTapped()
}

public protocol PledgeDisclaimerViewModelType {
  var inputs: PledgeDisclaimerViewModelInputs { get }
  var outputs: PledgeDisclaimerViewModelOutputs { get }
}

public final class PledgeDisclaimerViewModel: PledgeDisclaimerViewModelType,
  PledgeDisclaimerViewModelInputs, PledgeDisclaimerViewModelOutputs {
  public init() {
    self.notifyDelegatePresentTrustAndSafety = self.learnMoreTappedProperty.signal
  }

  private let learnMoreTappedProperty = MutableProperty(())
  public func learnMoreTapped() {
    self.learnMoreTappedProperty.value = ()
  }

  public let notifyDelegatePresentTrustAndSafety: Signal<Void, Never>

  public var inputs: PledgeDisclaimerViewModelInputs { return self }
  public var outputs: PledgeDisclaimerViewModelOutputs { return self }
}
