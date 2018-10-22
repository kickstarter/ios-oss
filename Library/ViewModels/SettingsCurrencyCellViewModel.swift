import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

public protocol SettingsCurrencyCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
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
    let initialUser = self.initialUserProperty.signal.skipNil()

    let emptyStringOnLoad = initialUser.signal.mapConst("")

    let fetchedCurrency = initialUser.signal
      .switchMap { _ in
        return AppEnvironment.current.apiService
          .fetchGraphCurrency(query: UserQueries.chosenCurrency.query)
          .materialize()
      }

    let chosenCurrency = fetchedCurrency.values().map {
      Currency(rawValue: $0.me.chosenCurrency ?? "")?.descriptionText ?? "" }

    self.chosenCurrencyText = Signal.merge(
      emptyStringOnLoad,
      chosenCurrency
    )
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  public func configure(with cellValue: SettingsCellValue) {
    self.initialUserProperty.value = cellValue.user
  }

  public let chosenCurrencyText: Signal<String, NoError>

  public var inputs: SettingsCurrencyCellViewModelInputs { return self }
  public var outputs: SettingsCurrencyCellViewModelOutputs { return self }
}
