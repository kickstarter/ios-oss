import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsAccountPickerCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
}

protocol SettingsAccountPickerCellViewModelOutputs {
  var currencyPickerHidden: Signal<Bool, NoError> { get }
  var notifyCurrencyPickerShouldCollapse: Signal<(), NoError> { get }
}

protocol SettingsAccountPickerCellViewModelType {
  var inputs: SettingsAccountPickerCellViewModelInputs { get }
  var outputs: SettingsAccountPickerCellViewModelOutputs { get }
}

final class SettingsAccountPickerCellViewModel: SettingsAccountPickerCellViewModelOutputs,
SettingsAccountPickerCellViewModelInputs, SettingsAccountPickerCellViewModelType {

  public init() {
    let cellType = cellTypeProperty.signal.skipNil().skipRepeats()

    self.currencyPickerHidden = .empty
//      cellType
//      .map { $0.hidePickerView }
//      .negate()

    self.notifyCurrencyPickerShouldCollapse =  .empty //self.tappedProperty.signal
  }

  private let cellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  func configure(with cellValue: SettingsCellValue) {
    self.cellTypeProperty.value = cellValue.cellType as? SettingsAccountCellType
  }

  public let currencyPickerHidden: Signal<Bool, NoError>
  public let notifyCurrencyPickerShouldCollapse: Signal<(), NoError>

  var inputs: SettingsAccountPickerCellViewModelInputs { return self }
  var outputs: SettingsAccountPickerCellViewModelOutputs { return self }
}
