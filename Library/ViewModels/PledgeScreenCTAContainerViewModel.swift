import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

protocol PledgeScreenCTAContainerViewDelegate: AnyObject {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)
}

public protocol PledgeScreenCTAContainerViewModelInputs {
  //func configureWith(value: PledgeCTAContainerViewData)
  func pledgeCTAButtonTapped()
}

public protocol PledgeScreenCTAContainerViewModelOutputs {
  var notifyDelegateCTATapped: Signal<Void, Never> { get }
}

public protocol PledgeScreenCTAContainerViewModelType {
  var inputs: PledgeScreenCTAContainerViewModelInputs { get }
  var outputs: PledgeScreenCTAContainerViewModelOutputs { get }
}

public final class PledgeScreenCTAContainerViewModel: PledgeScreenCTAContainerViewModelType,
  PledgeScreenCTAContainerViewModelInputs, PledgeScreenCTAContainerViewModelOutputs {
  public init() {
    self.notifyDelegateCTATapped = self.pledgeCTAButtonTappedProperty.signal
  }

//  fileprivate let configData = MutableProperty<PledgeCTAContainerViewData?>(nil)
//  public func configureWith(value: PledgeCTAContainerViewData) {
//    self.configData.value = value
//  }

  fileprivate let pledgeCTAButtonTappedProperty = MutableProperty(())
  public func pledgeCTAButtonTapped() {
    self.pledgeCTAButtonTappedProperty.value = ()
  }

  public let notifyDelegateCTATapped: Signal<Void, Never>


  public var inputs: PledgeScreenCTAContainerViewModelInputs { return self }
  public var outputs: PledgeScreenCTAContainerViewModelOutputs { return self }
}

