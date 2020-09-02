import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ShippingRuleCellViewModelInputs {
  func configureWith(_ value: ShippingRuleData)
}

public protocol ShippingRuleCellViewModelOutputs {
  var isSelected: Signal<Bool, Never> { get }
  var textLabelText: Signal<String, Never> { get }
}

public protocol ShippingRuleCellViewModelType {
  var inputs: ShippingRuleCellViewModelInputs { get }
  var outputs: ShippingRuleCellViewModelOutputs { get }
}

public final class ShippingRuleCellViewModel: ShippingRuleCellViewModelType,
  ShippingRuleCellViewModelInputs, ShippingRuleCellViewModelOutputs {
  public init() {
    let data = self.configDataProperty.signal
      .skipNil()

    self.isSelected = data
      .map { $0.selectedShippingRule == $0.shippingRule }

    self.textLabelText = data
      .map(\.shippingRule.location.localizedName)
  }

  private let configDataProperty = MutableProperty<ShippingRuleData?>(nil)
  public func configureWith(_ value: ShippingRuleData) {
    self.configDataProperty.value = value
  }

  public let isSelected: Signal<Bool, Never>
  public let textLabelText: Signal<String, Never>

  public var inputs: ShippingRuleCellViewModelInputs { return self }
  public var outputs: ShippingRuleCellViewModelOutputs { return self }
}
