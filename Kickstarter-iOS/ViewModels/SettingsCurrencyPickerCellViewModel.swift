import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsCurrencyPickerCellViewModelInputs {
  func didSelectCurrency(currency: Currency)
}

protocol SettingsCurrencyPickerCellViewModelOutputs {
  var showCurrencyChangeAlert: Signal<Currency, NoError> { get }
}

protocol SettingsCurrencyPickerCellViewModelType {
  var inputs: SettingsCurrencyPickerCellViewModelInputs { get }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { get }
}

final class SettingsCurrencyPickerCellViewModel: SettingsCurrencyPickerCellViewModelOutputs,
SettingsCurrencyPickerCellViewModelInputs, SettingsCurrencyPickerCellViewModelType {

  public init() {
    self.showCurrencyChangeAlert = self.selectedCurrencyProperty.signal.skipNil()
  }

  fileprivate let selectedCurrencyProperty = MutableProperty<Currency?>(nil)
  public func didSelectCurrency(currency: Currency) {
    self.selectedCurrencyProperty.value = currency
  }

  public let showCurrencyChangeAlert: Signal<Currency, NoError>

  var inputs: SettingsCurrencyPickerCellViewModelInputs { return self }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { return self }
}
