import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeScreenCTAContainerViewModelInputs {
  //func configureWith(value: PledgeCTAContainerViewData)
  func applePayButtonTapped()
  func pledgeCTAButtonTapped()
}

public protocol PledgeScreenCTAContainerViewModelOutputs {
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegatePledgeButtonTapped: Signal<Void, Never> { get }
}

public protocol PledgeScreenCTAContainerViewModelType {
  var inputs: PledgeScreenCTAContainerViewModelInputs { get }
  var outputs: PledgeScreenCTAContainerViewModelOutputs { get }
}

public final class PledgeScreenCTAContainerViewModel: PledgeScreenCTAContainerViewModelType,
  PledgeScreenCTAContainerViewModelInputs, PledgeScreenCTAContainerViewModelOutputs {
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

  public var inputs: PledgeScreenCTAContainerViewModelInputs { return self }
  public var outputs: PledgeScreenCTAContainerViewModelOutputs { return self }
}

