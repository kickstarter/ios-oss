import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

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
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var deselectCellAtIndex: Signal<Int, NoError> { get }
  var didUpdateCurrency: Signal<(), NoError> { get }
  var reloadDataWithCurrencies: Signal<([SelectedCurrencyData], Bool), NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var selectCellAtIndex: Signal<Int, NoError> { get }
  var updateCurrencyDidFailWithError: Signal<String, NoError> { get }
  var updateCurrencyDidSucceed: Signal<Void, NoError> { get }
}

public protocol SelectCurrencyViewModelType {
  var inputs: SelectCurrencyViewModelInputs { get }
  var outputs: SelectCurrencyViewModelOutputs { get }
}

final public class SelectCurrencyViewModel: SelectCurrencyViewModelType, SelectCurrencyViewModelInputs,
SelectCurrencyViewModelOutputs {

  public init() {
    let initialChosenCurrency = Signal.combineLatest(
      self.selectedCurrencySignal,
      self.viewDidLoadSignal
    )
    .map(first)

    let orderedCurrencies = initialChosenCurrency
      .map { currencies(orderedBySelected: $0)}

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
    .map { currencies(orderedBySelected: $1).index(of: $0) }
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

    updatedCurrency
      .observeValues { AppEnvironment.current.koala.trackChangedCurrency($0) }

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

  private let (selectedCurrencySignal, selectedCurrencyObserver) = Signal<Currency, NoError>.pipe()
  public func configure(with selectedCurrency: Currency) {
    self.selectedCurrencyObserver.send(value: selectedCurrency)
  }

  private let (didSelectCurrencyAtIndexSignal, didSelectCurrencyAtIndexObserver)
    = Signal<Int, NoError>.pipe()
  public func didSelectCurrency(atIndex index: Int) {
    self.didSelectCurrencyAtIndexObserver.send(value: index)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), NoError>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  private let (saveButtonTappedSignal, saveButtonTappedObserver) = Signal<(), NoError>.pipe()
  public func saveButtonTapped() {
    self.saveButtonTappedObserver.send(value: ())
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let deselectCellAtIndex: Signal<Int, NoError>
  public let didUpdateCurrency: Signal<(), NoError>
  public let reloadDataWithCurrencies: Signal<([SelectedCurrencyData], Bool), NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let selectCellAtIndex: Signal<Int, NoError>
  public let updateCurrencyDidFailWithError: Signal<String, NoError>
  public let updateCurrencyDidSucceed: Signal<Void, NoError>

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
