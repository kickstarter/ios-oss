import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol PledgeDescriptionCellViewModelInputs {
  func configureWith(estimatedDeliveryDate: String)
  func tapped()
}

public protocol PledgeDescriptionCellViewModelOutputs {
  var estimatedDeliveryText: Signal<String, NoError> { get }
  var presentTrustAndSafety: Signal<Void, NoError> { get }
}

public protocol PledgeDescriptionCellViewModelType {
  var inputs: PledgeDescriptionCellViewModelInputs { get }
  var outputs: PledgeDescriptionCellViewModelOutputs { get }
}

public final class PledgeDescriptionCellViewModel: PledgeDescriptionCellViewModelType,
PledgeDescriptionCellViewModelInputs, PledgeDescriptionCellViewModelOutputs {

  public init() {
    self.estimatedDeliveryText = self.estimatedDeliveryDateProperty.signal

    self.presentTrustAndSafety = self.tappedProperty.signal
  }

  private let estimatedDeliveryDateProperty = MutableProperty<String>("")
  public func configureWith(estimatedDeliveryDate: String) {
    self.estimatedDeliveryDateProperty.value = estimatedDeliveryDate
  }
  private let tappedProperty = MutableProperty(())
  public func tapped() {
    self.tappedProperty.value = ()
  }

  public let estimatedDeliveryText: Signal<String, NoError>
  public let presentTrustAndSafety: Signal<Void, NoError>

  public var inputs: PledgeDescriptionCellViewModelInputs { return self }
  public var outputs: PledgeDescriptionCellViewModelOutputs { return self }
}
