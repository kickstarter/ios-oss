import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

public protocol SettingsCurrencyCellViewModelInputs {
  func configure(with cellValue: SettingsCurrencyCellValue)
}

public protocol SettingsCurrencyCellViewModelOutputs {
  var chosenCurrencyText: Signal<String, NoError> { get }
}

public protocol SettingsCurrencyCellViewModelType {
  var inputs: SettingsCurrencyCellViewModelInputs { get }
  var outputs: SettingsCurrencyCellViewModelOutputs { get }
}

public final class SettingsCurrencyCellViewModel: SettingsCurrencyCellViewModelType,
SettingsCurrencyCellViewModelInputs, SettingsCurrencyCellViewModelOutputs {

  public init() {
    self.chosenCurrencyText = self.currencyProperty.signal.skipNil()
      .map { $0.descriptionText }
  }

  fileprivate let currencyProperty = MutableProperty<Currency?>(nil)
  public func configure(with cellValue: SettingsCurrencyCellValue) {
    self.currencyProperty.value = cellValue.currency
  }

  public let chosenCurrencyText: Signal<String, NoError>

  public var inputs: SettingsCurrencyCellViewModelInputs { return self }
  public var outputs: SettingsCurrencyCellViewModelOutputs { return self }
}
