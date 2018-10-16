import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

public protocol SettingsCurrencyCellViewModelInputs {
  func configure(with cellValue: SettingsCellValue)
}

public protocol SettingsCurrencyCellViewModelOutputs {
  var fetchedCurrency: Signal<UserCurrency, NoError> { get }
  var chosenCurrencyText: Signal<String, NoError> { get }
  var fetchUserError: Signal<GraphError, NoError> { get }
}

public protocol SettingsCurrencyCellViewModelType {
  var inputs: SettingsCurrencyCellViewModelInputs { get }
  var outputs: SettingsCurrencyCellViewModelOutputs { get }
}

public final class SettingsCurrencyCellViewModel: SettingsCurrencyCellViewModelType,
SettingsCurrencyCellViewModelInputs, SettingsCurrencyCellViewModelOutputs {

  public init() {
    let initialUser = self.initialUserProperty.signal.skipNil()

    let fetchedCurrency = initialUser.signal
      .switchMap { _ in
        return AppEnvironment.current.apiService
          .fetchGraphCurrency(query: UserQueries.chosenCurrency.query)
          .materialize()
      }

    self.fetchedCurrency = fetchedCurrency.values().map { $0.me }

    self.chosenCurrencyText = fetchedCurrency.values().map { Currency(rawValue: $0.me.chosenCurrency ?? "")?.descriptionText ?? "" }

    self.fetchUserError = fetchedCurrency.errors()
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  public func configure(with cellValue: SettingsCellValue) {
    self.initialUserProperty.value = cellValue.user
  }

  public let fetchedCurrency: Signal<UserCurrency, NoError>
  public let fetchUserError: Signal<GraphError, NoError>
  public let chosenCurrencyText: Signal<String, NoError>

  public var inputs: SettingsCurrencyCellViewModelInputs { return self }
  public var outputs: SettingsCurrencyCellViewModelOutputs { return self }
}
