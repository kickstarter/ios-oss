import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct ShippingRuleData: Equatable {
  public let selectedShippingRule: ShippingRule
  public let shippingRule: ShippingRule
}

private typealias ShippingRulesInputData = (
  project: Project, shippingRules: [ShippingRule], initialSelectedShippingRule: ShippingRule
)

public protocol ShippingRulesViewModelInputs {
  func configureWith(_ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule)
  func didSelectShippingRule(at index: Int)
  func searchTextDidChange(_ searchText: String)
  func viewDidLayoutSubviews()
  func viewDidLoad()
}

public protocol ShippingRulesViewModelOutputs {
  var deselectVisibleCells: Signal<Void, Never> { get }
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
    .map { data in
      (
        project: data.project,
        shippingRules: data.shippingRules.sorted { $0.location.localizedName < $1.location.localizedName },
        initialSelectedShippingRule: data.initialSelectedShippingRule
      )
    }

    let searchText = self.searchTextDidChangeProperty.signal
      .ksr_debounce(.milliseconds(100), on: AppEnvironment.current.scheduler)
      .skipNil()

    let selectedIndex = self.didSelectShippingRuleAtIndexProperty.signal
      .skipNil()

    self.deselectVisibleCells = selectedIndex
      .ignoreValues()

    let filteredData = initialData
      .takePairWhen(searchText)
      .map(dataMatching(_:searchText:))

    let selectedShippingRuleInitial = initialData
      .map(third)

    let selectedShippingRule = Signal.merge(
      initialData,
      filteredData
    )
    .takePairWhen(selectedIndex)
    .map { data, selectedIndex in data.shippingRules[selectedIndex] }

    let selectedShippingRuleCurrent = Signal.merge(
      selectedShippingRuleInitial,
      selectedShippingRule
    )

    self.notifyDelegateOfSelectedShippingRule = selectedShippingRule
      .skipRepeats()

    let reloadDataInitial = initialData
      .map { _, shippingRules, selectedShippingRule in (shippingRules, selectedShippingRule) }
      .map(shippingRulesData)
      .map { ($0, true) }

    let reloadDataFiltered = filteredData
      .withLatest(from: selectedShippingRuleCurrent)
      .map { data, selectedShippingRule in (data.shippingRules, selectedShippingRule) }
      .map(shippingRulesData)
      .map { ($0, true) }

    let reloadDataSelected = Signal.merge(
      initialData,
      filteredData
    )
    .takePairWhen(selectedShippingRule)
    .map { data, selectedShippingRule in (data.shippingRules, selectedShippingRule) }
    .map(shippingRulesData)
    .map { ($0, false) }

    let viewDidLayoutSubviews = self.viewDidLayoutSubviewsProperty.signal
      .take(first: 1)

    let initialDataAfterViewDidLayoutSubviews = initialData
      .takeWhen(viewDidLayoutSubviews)

    self.flashScrollIndicators = initialDataAfterViewDidLayoutSubviews
      .ignoreValues()

    self.reloadDataWithShippingRules = Signal.merge(
      reloadDataInitial,
      reloadDataFiltered,
      reloadDataSelected
    )

    self.scrollToCellAtIndex = Signal.merge(
      initialDataAfterViewDidLayoutSubviews,
      filteredData
    )
    .map { _, shippingRules, selectedShippingRule in shippingRules.firstIndex(of: selectedShippingRule) }
    .skipNil()

    self.selectCellAtIndex = selectedIndex
  }

  private let configDataProperty = MutableProperty<ShippingRulesInputData?>(nil)
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

  private let viewDidLayoutSubviewsProperty = MutableProperty(())
  public func viewDidLayoutSubviews() {
    self.viewDidLayoutSubviewsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let deselectVisibleCells: Signal<Void, Never>
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
  shippingRules: [ShippingRule],
  selectedShippingRule: ShippingRule
) -> [ShippingRuleData] {
  return shippingRules.map {
    ShippingRuleData(selectedShippingRule: selectedShippingRule, shippingRule: $0)
  }
}

private func dataMatching(
  _ data: (project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule),
  searchText: String
)
  -> ShippingRulesInputData {
  let filteredRules = data.shippingRules.filter {
    searchText.count == 0 ||
      $0.location.localizedName.lowercased().hasPrefix(searchText.lowercased())
  }
  return (data.project, filteredRules, data.selectedShippingRule)
}
