import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsAccountPickerCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
  func didSelectCurrency(currency: Currency)
}

protocol SettingsAccountPickerCellViewModelOutputs {
  var notifyCurrencyPickerCellRemoved: Signal<Bool, NoError> { get }
  var updateCurrencyDetailText: Signal<String, NoError> { get }
}

protocol SettingsAccountPickerCellViewModelType {
  var inputs: SettingsAccountPickerCellViewModelInputs { get }
  var outputs: SettingsAccountPickerCellViewModelOutputs { get }
}

final class SettingsAccountPickerCellViewModel: SettingsAccountPickerCellViewModelOutputs,
SettingsAccountPickerCellViewModelInputs, SettingsAccountPickerCellViewModelType {

  public init() {
    self.notifyCurrencyPickerCellRemoved = self.selectedCurrencyProperty.signal.mapConst(true)

    self.updateCurrencyDetailText = self.selectedCurrencyProperty.signal.skipNil()
      .map { $0.descriptionText }
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
  public let updateCurrencyDetailText: Signal<String, NoError>

  var inputs: SettingsAccountPickerCellViewModelInputs { return self }
  var outputs: SettingsAccountPickerCellViewModelOutputs { return self }
}
