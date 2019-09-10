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
  func searchTextDidChange(_ searchText: String)
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
    let initialData = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configDataProperty.signal
    )
    .map(second)
    .skipNil()

    let searchText = self.searchTextDidChangeProperty.signal
      .ksr_debounce(.milliseconds(100), on: AppEnvironment.current.scheduler)
      .skipNil()

    let selectedIndex = self.didSelectShippingRuleAtIndexProperty.signal
      .skipNil()

    self.deselectCellAtIndex = selectedIndex

    let filteredData = initialData
      .takePairWhen(searchText)
      .map(dataMatching(_:searchText:))

    let selectedShippingRule = Signal.merge(
      initialData,
      filteredData
    )
    .takePairWhen(selectedIndex)
    .map { data, selectedIndex in (data.1, selectedIndex) }
    .map { shippingRules, selectedIndex in shippingRules[selectedIndex] }

    self.notifyDelegateOfSelectedShippingRule = selectedShippingRule
      .skipRepeats()

    let reloadDataInitial = initialData
      .map(shippingRulesData(project:shippingRules:selectedShippingRule:))
      .map { ($0, true) }

    let reloadDataFiltered = filteredData
      .withLatest(from: Signal.merge(initialData.map(third), selectedShippingRule))
      .map { data, selectedShippingRule in (data.0, data.1, selectedShippingRule) }
      .map(shippingRulesData(project:shippingRules:selectedShippingRule:))
      .map { ($0, true) }

    let reloadDataSelected = Signal.merge(
      initialData,
      filteredData
    )
    .takePairWhen(selectedIndex)
    .map { data, selectedIndex in (data.0, data.1, selectedIndex) }
    .map { project, shippingRules, selectedIndex in (project, shippingRules, shippingRules[selectedIndex]) }
    .map(shippingRulesData(project:shippingRules:selectedShippingRule:))
    .map { ($0, false) }

    self.flashScrollIndicators = initialData
      .take(first: 1)
      .ignoreValues()

    self.reloadDataWithShippingRules = Signal.merge(
      reloadDataInitial,
      reloadDataFiltered,
      reloadDataSelected
    )

    self.scrollToCellAtIndex = initialData
      .take(first: 1)
      .map { _, shippingRules, selectedShippingRule in shippingRules.firstIndex(of: selectedShippingRule) }
      .skipNil()

    self.selectCellAtIndex = self.deselectCellAtIndex
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

  private let searchTextDidChangeProperty = MutableProperty<String?>(nil)
  public func searchTextDidChange(_ searchText: String) {
    self.searchTextDidChangeProperty.value = searchText
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let deselectCellAtIndex: Signal<Int, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let notifyDelegateOfSelectedShippingRule: Signal<ShippingRule, Never>
  public let reloadDataWithShippingRules: Signal<([ShippingRuleData], Bool), Never>
  public let scrollToCellAtIndex: Signal<Int, Never>
  public let selectCellAtIndex: Signal<Int, Never>

  public var inputs: ShippingRulesViewModelInputs { return self }
  public var outputs: ShippingRulesViewModelOutputs { return self }
}

// MARK: - Functions

private func shippingRulesData(
  project: Project,
  shippingRules: [ShippingRule],
  selectedShippingRule: ShippingRule
) -> [ShippingRuleData] {
  return shippingRules.map {
    ShippingRuleData(project: project, selectedShippingRule: selectedShippingRule, shippingRule: $0)
  }
}

private func dataMatching(
  _ data: (project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule),
  searchText: String)
  -> (Project, [ShippingRule], ShippingRule) {
  let filteredRules = data.shippingRules.filter {
    searchText.count == 0 ||
      $0.location.localizedName.lowercased().hasPrefix(searchText.lowercased())
  }
  return (data.project, filteredRules, data.selectedShippingRule)
}
