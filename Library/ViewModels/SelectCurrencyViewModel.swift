import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SelectCurrencyViewModelInputs {
  func configure(with selectedCurrency: Currency)
  func didSelect(_ currency: Currency)
  func viewDidLoad()
}

public protocol SelectCurrencyViewModelOutputs {
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

  private let selectedCurrencyProperty = MutableProperty<Currency?>(nil)
  public func isSelectedCurrency(_ currency: Currency) -> Bool {
    return currency == self.selectedCurrencyProperty.value
  }

  public var inputs: SelectCurrencyViewModelInputs { return self }
  public var outputs: SelectCurrencyViewModelOutputs { return self }
}
