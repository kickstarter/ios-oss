import KsApi
import Prelude
import ReactiveSwift

protocol SettingsAccountPickerCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
  func didSelectCurrency(currency: Currency)
}

protocol SettingsAccountPickerCellViewModelOutputs {
  var notifyCurrencyPickerCellRemoved: Signal<Bool, Never> { get }
  var updateCurrencyDetailText: Signal<String, Never> { get }
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

  public let notifyCurrencyPickerCellRemoved: Signal<Bool, Never>
  public let updateCurrencyDetailText: Signal<String, Never>

  var inputs: SettingsAccountPickerCellViewModelInputs { return self }
  var outputs: SettingsAccountPickerCellViewModelOutputs { return self }
}
