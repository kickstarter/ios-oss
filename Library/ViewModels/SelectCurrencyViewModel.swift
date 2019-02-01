import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SelectCurrencyViewModelInputs {
  func configure(with selectedCurrency: Currency)
  func didSelect(_ currency: Currency)
  func saveButtonTapped()
  func viewDidLoad()
}

public protocol SelectCurrencyViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var updateCurrencyDidFailWithError: Signal<String, NoError> { get }
  var updateCurrencyDidSucceed: Signal<Void, NoError> { get }

  func isSelectedCurrency(_ currency: Currency) -> Bool
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

    self.selectedCurrencyProperty <~ Signal.merge(
      initialChosenCurrency,
      self.didSelectCurrencySignal
    )

    let updateCurrencyEvent = self.selectedCurrencyProperty.signal.skipNil()
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
      self.didSelectCurrencySignal
    )

    let updatedAndSelected = Signal.combineLatest(
      updatedCurrency,
      self.didSelectCurrencySignal
    )

    let currenciesMatch = Signal.merge(
      initialAndSelected,
      updatedAndSelected
      )
      .map(!=)

    self.saveButtonIsEnabled = Signal.merge(
      self.viewDidLoadSignal.mapConst(false),
      currenciesMatch
    )
  }

  private let (selectedCurrencySignal, selectedCurrencyObserver) = Signal<Currency, NoError>.pipe()
  public func configure(with selectedCurrency: Currency) {
    self.selectedCurrencyObserver.send(value: selectedCurrency)
  }

  private let (didSelectCurrencySignal, didSelectCurrencyObserver) = Signal<Currency, NoError>.pipe()
  public func didSelect(_ currency: Currency) {
    self.didSelectCurrencyObserver.send(value: currency)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), NoError>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  private let (saveButtonTappedSignal, saveButtonTappedObserver) = Signal<(), NoError>.pipe()
  public func saveButtonTapped() {
    self.saveButtonTappedObserver.send(value: ())
  }

  private let selectedCurrencyProperty = MutableProperty<Currency?>(nil)
  public func isSelectedCurrency(_ currency: Currency) -> Bool {
    return currency == self.selectedCurrencyProperty.value
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let updateCurrencyDidFailWithError: Signal<String, NoError>
  public let updateCurrencyDidSucceed: Signal<Void, NoError>

  public var inputs: SelectCurrencyViewModelInputs { return self }
  public var outputs: SelectCurrencyViewModelOutputs { return self }
}
