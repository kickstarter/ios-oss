import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeViewCTAContainerViewModelInputs {
  // func configureWith(value: PledgeCTAContainerViewData)
  func applePayButtonTapped()
  func pledgeCTAButtonTapped()
}

public protocol PledgeViewCTAContainerViewModelOutputs {
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegatePledgeButtonTapped: Signal<Void, Never> { get }
}

public protocol PledgeViewCTAContainerViewModelType {
  var inputs: PledgeViewCTAContainerViewModelInputs { get }
  var outputs: PledgeViewCTAContainerViewModelOutputs { get }
}

public final class PledgeViewCTAContainerViewModel: PledgeViewCTAContainerViewModelType,
  PledgeViewCTAContainerViewModelInputs, PledgeViewCTAContainerViewModelOutputs {
  public init() {
    self.notifyDelegatePledgeButtonTapped = self.pledgeCTAButtonTappedProperty.signal
    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  fileprivate let pledgeCTAButtonTappedProperty = MutableProperty(())
  public func pledgeCTAButtonTapped() {
    self.pledgeCTAButtonTappedProperty.value = ()
  }

  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegatePledgeButtonTapped: Signal<Void, Never>

  public var inputs: PledgeViewCTAContainerViewModelInputs { return self }
  public var outputs: PledgeViewCTAContainerViewModelOutputs { return self }
}
