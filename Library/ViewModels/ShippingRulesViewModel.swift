import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct ShippingRuleData: Equatable {
  public let project: Project
  public let selectedShippingRule: ShippingRule
  public let shippingRule: ShippingRule
}

public protocol ShippingRulesViewModelInputs {
  func configureWith(_ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule)
  func viewDidLoad()
}

public protocol ShippingRulesViewModelOutputs {
  var loadValues: Signal<[ShippingRuleData], Never> { get }
}

public protocol ShippingRulesViewModelType {
  var inputs: ShippingRulesViewModelInputs { get }
  var outputs: ShippingRulesViewModelOutputs { get }
}

public final class ShippingRulesViewModel: ShippingRulesViewModelType,
  ShippingRulesViewModelInputs, ShippingRulesViewModelOutputs {
  public init() {
    self.loadValues = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configDataProperty.signal
    )
    .map(second)
    .skipNil()
    .map(shippingRuleData(for:shippingRules:selectedShippingRule:))
  }

  private let configDataProperty = MutableProperty<(Project, [ShippingRule], ShippingRule)?>(nil)
  public func configureWith(
    _ project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule
  ) {
    self.configDataProperty.value = (project, shippingRules, selectedShippingRule)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadValues: Signal<[ShippingRuleData], Never>

  public var inputs: ShippingRulesViewModelInputs { return self }
  public var outputs: ShippingRulesViewModelOutputs { return self }
}

// MARK: - Functions

private func shippingRuleData(
  for project: Project,
  shippingRules: [ShippingRule],
  selectedShippingRule: ShippingRule
) -> [ShippingRuleData] {
  return shippingRules.map {
    ShippingRuleData(project: project, selectedShippingRule: selectedShippingRule, shippingRule: $0)
  }
}
