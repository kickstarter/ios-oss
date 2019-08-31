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
  func didSelectShippingRule(at index: Int)
  func viewDidLoad()
}

public protocol ShippingRulesViewModelOutputs {
  var deselectCellAtIndex: Signal<Int, Never> { get }
  var selectCellAtIndex: Signal<Int, Never> { get }
  var reloadDataWithShippingRules: Signal<([ShippingRuleData], Bool), Never> { get }
}

public protocol ShippingRulesViewModelType {
  var inputs: ShippingRulesViewModelInputs { get }
  var outputs: ShippingRulesViewModelOutputs { get }
}

public final class ShippingRulesViewModel: ShippingRulesViewModelType,
  ShippingRulesViewModelInputs, ShippingRulesViewModelOutputs {
  public init() {
    let dataInitial = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configDataProperty.signal
    )
    .map(second)
    .skipNil()

    let dataSelected = Signal.combineLatest(
      dataInitial,
      self.didSelectShippingRuleAtIndexProperty.signal.skipNil()
    )
    .map { data, index in (data.0, data.1, index) }
    .filter { _, shippingRules, index in 0 <= index && index < shippingRules.count }
    .map { project, shippingRules, index in (project, shippingRules, shippingRules[index]) }

    let selectedShippingRuleIndexInitial = dataInitial
      .map { _, shippingRules, selectedShippingRule in shippingRules.firstIndex(of: selectedShippingRule) }
      .skipNil()

    let selectedShippingRuleIndexSelected = self.didSelectShippingRuleAtIndexProperty.signal
      .skipNil()

    self.selectCellAtIndex = Signal.merge(
      selectedShippingRuleIndexInitial,
      selectedShippingRuleIndexSelected
    )
    .skipRepeats()

    self.deselectCellAtIndex = self.selectCellAtIndex
      .combinePrevious()
      .map(first)

    let reloadDataWithShippingRulesInitial = dataInitial
      .map(shippingRuleData(for:shippingRules:selectedShippingRule:))
      .map { ($0, true) }

    let reloadDataWithShippingRulesSelected = dataSelected
      .map(shippingRuleData(for:shippingRules:selectedShippingRule:))
      .map { ($0, false) }

    self.reloadDataWithShippingRules = Signal.merge(
      reloadDataWithShippingRulesInitial,
      reloadDataWithShippingRulesSelected
    )
  }

  private let configDataProperty = MutableProperty<(Project, [ShippingRule], ShippingRule)?>(nil)
  public func configureWith(
    _ project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule
  ) {
    self.configDataProperty.value = (project, shippingRules, selectedShippingRule)
  }

  private let didSelectShippingRuleAtIndexProperty = MutableProperty<Int?>(nil)
  public func didSelectShippingRule(at index: Int) {
    self.didSelectShippingRuleAtIndexProperty.value = index
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let deselectCellAtIndex: Signal<Int, Never>
  public let selectCellAtIndex: Signal<Int, Never>
  public let reloadDataWithShippingRules: Signal<([ShippingRuleData], Bool), Never>

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
