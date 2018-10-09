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
}

protocol SettingsCurrencyPickerCellViewModelType {
  var inputs: SettingsCurrencyPickerCellViewModelInputs { get }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { get }
}

final class SettingsCurrencyPickerCellViewModel: SettingsCurrencyPickerCellViewModelOutputs,
SettingsCurrencyPickerCellViewModelInputs, SettingsCurrencyPickerCellViewModelType {

  public init() {
    self.notifyCurrencyPickerCellRemoved = self.selectedCurrencyProperty.signal.mapConst(true)
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

  var inputs: SettingsCurrencyPickerCellViewModelInputs { return self }
  var outputs: SettingsCurrencyPickerCellViewModelOutputs { return self }
}
