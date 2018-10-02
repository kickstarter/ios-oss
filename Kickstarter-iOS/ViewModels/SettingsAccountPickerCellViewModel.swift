import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsAccountPickerCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
  func didSelectCurrency(currency: Currencies)
}

protocol SettingsAccountPickerCellViewModelOutputs {
  var notifyCurrencyPickerHidden: Signal<Bool, NoError> { get }
  var notifyCurrencySelected: Signal<String, NoError> { get }
}

protocol SettingsAccountPickerCellViewModelType {
  var inputs: SettingsAccountPickerCellViewModelInputs { get }
  var outputs: SettingsAccountPickerCellViewModelOutputs { get }
}

final class SettingsAccountPickerCellViewModel: SettingsAccountPickerCellViewModelOutputs,
SettingsAccountPickerCellViewModelInputs, SettingsAccountPickerCellViewModelType {

  public init() {
    let cellType = cellTypeProperty.signal.skipNil().skipRepeats()

    self.notifyCurrencyPickerHidden = selectedCurrencyProperty.signal.mapConst(true)

    self.notifyCurrencySelected = selectedCurrencyProperty.signal.map { $0?.descriptionText ?? "" }
  }

  fileprivate let selectedCurrencyProperty = MutableProperty<Currencies?>(nil)
  public func didSelectCurrency(currency: Currencies) {
    self.selectedCurrencyProperty.value = currency
  }

  private let cellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  func configure(with cellValue: SettingsCellValue) {
    self.cellTypeProperty.value = cellValue.cellType as? SettingsAccountCellType
  }

  public let notifyCurrencyPickerHidden: Signal<Bool, NoError>
  public let notifyCurrencySelected: Signal<String, NoError>

  var inputs: SettingsAccountPickerCellViewModelInputs { return self }
  var outputs: SettingsAccountPickerCellViewModelOutputs { return self }
}
