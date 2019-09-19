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
      .map { ($0.project, $0.shippingRule) }
      .map(formattedValue(_:shippingRule:))
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

// MARK: - Functions

private func formattedValue(_ project: Project, shippingRule: ShippingRule) -> String {
  let locationName = shippingRule.location.localizedName
  let shippingCost = Strings.plus_shipping_cost(
    shipping_cost: Format.currency(shippingRule.cost, country: project.country)
  )

  return "\(locationName) (\(shippingCost))"
}
