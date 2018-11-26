import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsCurrencyPickerCellViewModelInputs {
  func didSelectCurrency(currency: Currency)
}

public protocol SettingsCurrencyPickerCellViewModelOutputs {
  var showCurrencyChangeAlert: Signal<Currency, NoError> { get }
}

public protocol SettingsCurrencyPickerCellViewModelType {
  var inputs: SettingsCurrencyPickerCellViewModelInputs { get }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { get }
}

public final class SettingsCurrencyPickerCellViewModel: SettingsCurrencyPickerCellViewModelOutputs,
SettingsCurrencyPickerCellViewModelInputs, SettingsCurrencyPickerCellViewModelType {

  public init() {
    self.showCurrencyChangeAlert = self.selectedCurrencyProperty.signal.skipNil()
  }

  fileprivate let selectedCurrencyProperty = MutableProperty<Currency?>(nil)
  public func didSelectCurrency(currency: Currency) {
    self.selectedCurrencyProperty.value = currency
  }

  public let showCurrencyChangeAlert: Signal<Currency, NoError>

  public var inputs: SettingsCurrencyPickerCellViewModelInputs { return self }
  public var outputs: SettingsCurrencyPickerCellViewModelOutputs { return self }
}
