import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
public protocol PledgeDescriptionCellViewModelInputs {
  func configureWith(estimatedDeliveryDate: String)
  func learnMoreTapped()
}

public protocol PledgeDescriptionCellViewModelOutputs {
  var estimatedDeliveryText: Signal<String, Never> { get }
  var presentTrustAndSafety: Signal<Void, Never> { get }
}

public protocol PledgeDescriptionCellViewModelType {
  var inputs: PledgeDescriptionCellViewModelInputs { get }
  var outputs: PledgeDescriptionCellViewModelOutputs { get }
}

public final class PledgeDescriptionCellViewModel: PledgeDescriptionCellViewModelType,
  PledgeDescriptionCellViewModelInputs, PledgeDescriptionCellViewModelOutputs {
  public init() {
    self.estimatedDeliveryText = self.estimatedDeliveryDateProperty.signal

    self.presentTrustAndSafety = self.learnMoreTappedProperty.signal
  }

  private let estimatedDeliveryDateProperty = MutableProperty<String>("")
  public func configureWith(estimatedDeliveryDate: String) {
    self.estimatedDeliveryDateProperty.value = estimatedDeliveryDate
  }

  private let learnMoreTappedProperty = MutableProperty(())
  public func learnMoreTapped() {
    self.learnMoreTappedProperty.value = ()
  }

  public let estimatedDeliveryText: Signal<String, Never>
  public let presentTrustAndSafety: Signal<Void, Never>

  public var inputs: PledgeDescriptionCellViewModelInputs { return self }
  public var outputs: PledgeDescriptionCellViewModelOutputs { return self }
}
