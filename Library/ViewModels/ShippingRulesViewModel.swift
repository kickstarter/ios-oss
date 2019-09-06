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
  var flashScrollIndicators: Signal<Void, Never> { get }
  var notifyDelegateOfSelectedShippingRule: Signal<ShippingRule, Never> { get }
  var reloadDataWithShippingRules: Signal<([ShippingRuleData], Bool), Never> { get }
  var scrollToCellAtIndex: Signal<Int, Never> { get }
  var selectCellAtIndex: Signal<Int, Never> { get }
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

    let selectedIndex = Signal.combineLatest(
      dataInitial,
      self.didSelectShippingRuleAtIndexProperty.signal.skipNil()
    )
    .map { data, newIndex in (data.1.firstIndex(of: data.2), newIndex) }
    .filter { oldIndex, newIndex in oldIndex != newIndex }
    .map(second)

    let dataSelected = Signal.combineLatest(
      dataInitial,
      selectedIndex
    )
    .map { data, index in (data.0, data.1, index) }
    .filter { _, shippingRules, index in index >= 0 && index < shippingRules.count }
    .map { project, shippingRules, index in (project, shippingRules, shippingRules[index]) }

    let reloadDataWithShippingRulesInitial = dataInitial
      .map { project, shippingRules, selectedShippingRule in
        shippingRules.map {
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: $0
          )
        }
      }
      .map { ($0, true) }

    let reloadDataWithShippingRulesSelected = dataSelected
      .map { project, shippingRules, selectedShippingRule in
        shippingRules.map {
          ShippingRuleData(
            project: project, selectedShippingRule: selectedShippingRule, shippingRule: $0
          )
        }
      }
      .map { ($0, false) }

    self.reloadDataWithShippingRules = Signal.merge(
      reloadDataWithShippingRulesInitial,
      reloadDataWithShippingRulesSelected
    )

    self.flashScrollIndicators = reloadDataWithShippingRulesInitial
      .ignoreValues()

    let selectedShippingRuleIndexInitial = dataInitial
      .map { _, shippingRules, selectedShippingRule in shippingRules.firstIndex(of: selectedShippingRule) }
      .skipNil()

    let selectedShippingRuleIndexSelected = self.didSelectShippingRuleAtIndexProperty.signal
      .skipNil()

    self.notifyDelegateOfSelectedShippingRule = dataSelected
      .map(third)

    self.scrollToCellAtIndex = Signal.combineLatest(
      selectedShippingRuleIndexInitial,
      reloadDataWithShippingRulesInitial
    )
    .map(first)

    self.selectCellAtIndex = Signal.merge(
      selectedShippingRuleIndexInitial,
      selectedShippingRuleIndexSelected
    )
    .skipRepeats()

    self.deselectCellAtIndex = self.selectCellAtIndex
      .combinePrevious()
      .map(first)
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
  public let notifyDelegateOfSelectedShippingRule: Signal<ShippingRule, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let reloadDataWithShippingRules: Signal<([ShippingRuleData], Bool), Never>
  public let scrollToCellAtIndex: Signal<Int, Never>
  public let selectCellAtIndex: Signal<Int, Never>

  public var inputs: ShippingRulesViewModelInputs { return self }
  public var outputs: ShippingRulesViewModelOutputs { return self }
}
