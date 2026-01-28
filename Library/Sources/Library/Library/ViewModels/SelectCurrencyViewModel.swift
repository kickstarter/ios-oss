import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct SelectedCurrencyData: Equatable {
  public let currency: Currency
  public let selected: Bool
}

public protocol SelectCurrencyViewModelInputs {
  func configure(with selectedCurrency: Currency)
  func didSelectCurrency(atIndex index: Int)
  func saveButtonTapped()
  func viewDidLoad()
}

public protocol SelectCurrencyViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, Never> { get }
  var deselectCellAtIndex: Signal<Int, Never> { get }
  var didUpdateCurrency: Signal<(), Never> { get }
  var reloadDataWithCurrencies: Signal<([SelectedCurrencyData], Bool), Never> { get }
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var selectCellAtIndex: Signal<Int, Never> { get }
  var updateCurrencyDidFailWithError: Signal<String, Never> { get }
  var updateCurrencyDidSucceed: Signal<Void, Never> { get }
}

public protocol SelectCurrencyViewModelType {
  var inputs: SelectCurrencyViewModelInputs { get }
  var outputs: SelectCurrencyViewModelOutputs { get }
}

public final class SelectCurrencyViewModel: SelectCurrencyViewModelType, SelectCurrencyViewModelInputs,
  SelectCurrencyViewModelOutputs {
  public init() {
    let initialChosenCurrency = Signal.combineLatest(
      self.selectedCurrencySignal,
      self.viewDidLoadSignal
    )
    .map(first)

    let orderedCurrencies = initialChosenCurrency
      .map { currencies(orderedBySelected: $0) }

    let didSelectCurrency = orderedCurrencies
      .takePairWhen(self.didSelectCurrencyAtIndexSignal)
      .map { $0[$1] }

    let orderedAndInitial = Signal.combineLatest(orderedCurrencies, initialChosenCurrency)
      .map { ($0, $1) }
      .map(selectedCurrencyData(with:selected:))
      .map { ($0, true) }

    let orderedAndSelected = Signal.combineLatest(orderedCurrencies, didSelectCurrency)
      .map { ($0, $1) }
      .map(selectedCurrencyData(with:selected:))
      .map { ($0, false) }

    self.reloadDataWithCurrencies = Signal.merge(
      orderedAndInitial,
      orderedAndSelected
    )

    let selectedCurrency = Signal.merge(initialChosenCurrency, didSelectCurrency)

    self.selectCellAtIndex = Signal.combineLatest(
      selectedCurrency,
      initialChosenCurrency
    )
    .map { currencies(orderedBySelected: $1).firstIndex(of: $0) }
    .skipNil()

    self.deselectCellAtIndex = self.selectCellAtIndex
      .combinePrevious()
      .map(first)

    let updateCurrencyEvent = didSelectCurrency
      .takeWhen(self.saveButtonTappedSignal.ignoreValues())
      .switchMap { input in
        AppEnvironment.current.apiService
          .changeCurrency(input: ChangeCurrencyInput(chosenCurrency: input.rawValue))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { _ in input }
          .materialize()
      }

    self.updateCurrencyDidSucceed = updateCurrencyEvent.values().ignoreValues()

    self.updateCurrencyDidFailWithError = updateCurrencyEvent.errors().map { $0.localizedDescription }

    self.activityIndicatorShouldShow = Signal.merge(
      self.saveButtonTappedSignal.mapConst(true),
      updateCurrencyEvent.filter { $0.isTerminating }.mapConst(false)
    )

    let updatedCurrency = updateCurrencyEvent.values()

    let initialAndSelected = Signal.combineLatest(
      initialChosenCurrency,
      didSelectCurrency
    )

    let updatedAndSelected = Signal.combineLatest(
      updatedCurrency,
      didSelectCurrency
    )

    let currenciesDoNotMatch = Signal.merge(
      initialAndSelected,
      updatedAndSelected
    )
    .map(!=)

    self.saveButtonIsEnabled = Signal.merge(
      self.viewDidLoadSignal.mapConst(false),
      currenciesDoNotMatch
    )

    self.didUpdateCurrency = updateCurrencyEvent.values().ignoreValues()
  }

  private let (selectedCurrencySignal, selectedCurrencyObserver) = Signal<Currency, Never>.pipe()
  public func configure(with selectedCurrency: Currency) {
    self.selectedCurrencyObserver.send(value: selectedCurrency)
  }

  private let (didSelectCurrencyAtIndexSignal, didSelectCurrencyAtIndexObserver)
    = Signal<Int, Never>.pipe()
  public func didSelectCurrency(atIndex index: Int) {
    self.didSelectCurrencyAtIndexObserver.send(value: index)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  private let (saveButtonTappedSignal, saveButtonTappedObserver) = Signal<(), Never>.pipe()
  public func saveButtonTapped() {
    self.saveButtonTappedObserver.send(value: ())
  }

  public let activityIndicatorShouldShow: Signal<Bool, Never>
  public let deselectCellAtIndex: Signal<Int, Never>
  public let didUpdateCurrency: Signal<(), Never>
  public let reloadDataWithCurrencies: Signal<([SelectedCurrencyData], Bool), Never>
  public let saveButtonIsEnabled: Signal<Bool, Never>
  public let selectCellAtIndex: Signal<Int, Never>
  public let updateCurrencyDidFailWithError: Signal<String, Never>
  public let updateCurrencyDidSucceed: Signal<Void, Never>

  public var inputs: SelectCurrencyViewModelInputs { return self }
  public var outputs: SelectCurrencyViewModelOutputs { return self }
}

internal func currencies(orderedBySelected selected: Currency) -> [Currency] {
  return Currency.allCases.sorted(by: { cur1, _ in cur1 == selected })
}

internal func selectedCurrencyData(with currencies: [Currency], selected: Currency)
  -> [SelectedCurrencyData] {
  return currencies.map { currency in .init(currency: currency, selected: currency == selected) }
}
