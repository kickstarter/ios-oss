import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsCurrencyPickerCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
  func didSelectCurrency(currency: Currency)
}

protocol SettingsCurrencyPickerCellViewModelOutputs {
  var notifyCurrencyPickerCellRemoved: Signal<Bool, NoError> { get }
  var showCurrencyChangeAlert: Signal<Currency, NoError> { get }
}

protocol SettingsCurrencyPickerCellViewModelType {
  var inputs: SettingsCurrencyPickerCellViewModelInputs { get }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { get }
}

final class SettingsCurrencyPickerCellViewModel: SettingsCurrencyPickerCellViewModelOutputs,
SettingsCurrencyPickerCellViewModelInputs, SettingsCurrencyPickerCellViewModelType {

  public init() {
    self.notifyCurrencyPickerCellRemoved = self.selectedCurrencyProperty.signal.mapConst(true) // fix this

    self.showCurrencyChangeAlert = self.selectedCurrencyProperty.signal.skipNil()
  }

  fileprivate let selectedCurrencyProperty = MutableProperty<Currency?>(nil)
  public func didSelectCurrency(currency: Currency) {
    self.selectedCurrencyProperty.value = currency
  }

  fileprivate let cellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  func configure(with cellValue: SettingsCellValue) {
    self.cellTypeProperty.value = cellValue.cellType as? SettingsAccountCellType
  }

  public let notifyCurrencyPickerCellRemoved: Signal<Bool, NoError>
  public let showCurrencyChangeAlert: Signal<Currency, NoError>

  var inputs: SettingsCurrencyPickerCellViewModelInputs { return self }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { return self }
}
