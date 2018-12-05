import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsAccountViewModelInputs {
  func didConfirmChangeCurrency()
  func dismissPickerTap()
  func didSelectRow(cellType: SettingsAccountCellType)
  func showChangeCurrencyAlert(for currency: Currency)
  func viewWillAppear()
  func viewDidAppear()
}

public protocol SettingsAccountViewModelOutputs {
  var dismissCurrencyPicker: Signal<Void, NoError> { get }
  var fetchAccountFieldsError: Signal<Void, NoError> { get }
  var presentCurrencyPicker: Signal<Void, NoError> { get }
  var reloadData: Signal<(Currency, Bool), NoError> { get }
  var showAlert: Signal<(), NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
  var updateCurrencyFailure: Signal<String, NoError> { get }
}

public protocol SettingsAccountViewModelType {
  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
SettingsAccountViewModelOutputs, SettingsAccountViewModelType {

  public init(_ viewControllerFactory: @escaping (SettingsAccountCellType) -> UIViewController?) {
    let userAccountFields = self.viewWillAppearProperty.signal
      .switchMap { _ in
        return AppEnvironment.current.apiService
          .fetchGraphUserAccountFields(query: UserQueries.account.query)
          .materialize()
    }

    self.fetchAccountFieldsError = userAccountFields.errors().ignoreValues()

    let shouldHideEmailWarning = userAccountFields.values()
      .map { response -> Bool in
        guard let isEmailVerified = response.me.isEmailVerified,
              let isDeliverable = response.me.isDeliverable else {
          return true
        }

        return isEmailVerified && isDeliverable
    }

    let chosenCurrency = userAccountFields.values()
      .map { Currency(rawValue: $0.me.chosenCurrency ?? Currency.USD.rawValue) ?? Currency.USD }

    let currencyCellSelected = self.selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .currency }

    let updateCurrencyEvent = self.changeCurrencyAlertProperty.signal.skipNil()
      .takeWhen(self.didConfirmChangeCurrencyProperty.signal)
      .map { ChangeCurrencyInput(chosenCurrency: $0.rawValue) }
      .switchMap {
        AppEnvironment.current.apiService.changeCurrency(input: $0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let updateCurrency = self.changeCurrencyAlertProperty.signal.skipNil()
      .takeWhen(updateCurrencyEvent.values().ignoreValues())

    self.updateCurrencyFailure = updateCurrencyEvent.errors()
      .map { $0.localizedDescription }

    let currency = Signal.merge(chosenCurrency, updateCurrency)

    self.reloadData = Signal.combineLatest(currency, shouldHideEmailWarning)

    self.presentCurrencyPicker = currencyCellSelected.signal.mapConst(true).ignoreValues()

    self.dismissCurrencyPicker = self.dismissPickerTapProperty.signal

    self.transitionToViewController = self.selectedCellTypeProperty.signal.skipNil()
      .map(viewControllerFactory)
      .skipNil()

    self.showAlert = self.changeCurrencyAlertProperty.signal.skipNil().ignoreValues()

    self.viewDidAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackAccountView() }

    // Koala
    updateCurrency.signal
      .observeValues { currency in
        AppEnvironment.current.koala.trackChangedCurrency(currency)
    }
  }

  fileprivate let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func didSelectRow(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let changeCurrencyAlertProperty = MutableProperty<Currency?>(nil)
  public func showChangeCurrencyAlert(for currency: Currency) {
    self.changeCurrencyAlertProperty.value = currency
  }

  fileprivate let dismissPickerTapProperty = MutableProperty(())
  public func dismissPickerTap() {
    self.dismissPickerTapProperty.value = ()
  }

  fileprivate let didConfirmChangeCurrencyProperty = MutableProperty(())
  public func didConfirmChangeCurrency() {
    self.didConfirmChangeCurrencyProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public let dismissCurrencyPicker: Signal<Void, NoError>
  public let fetchAccountFieldsError: Signal<Void, NoError>
  public let reloadData: Signal<(Currency, Bool), NoError>
  public let presentCurrencyPicker: Signal<Void, NoError>
  public let showAlert: Signal<(), NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>
  public let updateCurrencyFailure: Signal<String, NoError>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}
