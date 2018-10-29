import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

public protocol SettingsAccountViewModelInputs {
  func didConfirmChangeCurrency()
  func dismissPickerTap()
  func didSelectRow(cellType: SettingsAccountCellType)
  func showChangeCurrencyAlert(for currency: Currency)
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var dismissCurrencyPicker: Signal<Void, NoError> { get }
  var presentCurrencyPicker: Signal<Void, NoError> { get }
  var reloadData: Signal<(User, Currency), NoError> { get }
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

  public init() {
    let initialUser = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()

    let fetchedCurrency = self.viewDidLoadProperty.signal
      .switchMap { _ in
        return AppEnvironment.current.apiService
          .fetchGraphCurrency(query: UserQueries.chosenCurrency.query)
          .materialize()
    }

    let chosenCurrency = fetchedCurrency.values().map {
      Currency(rawValue: $0.me.chosenCurrency ?? Currency.USD.rawValue)
        ?? Currency.USD }

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

    self.reloadData = Signal.combineLatest(initialUser, currency)

    self.presentCurrencyPicker = currencyCellSelected.signal.mapConst(true).ignoreValues()

    self.dismissCurrencyPicker = self.dismissPickerTapProperty.signal

    self.transitionToViewController = self.selectedCellTypeProperty.signal.skipNil()
      .map { SettingsAccountViewModel.viewController(for: $0) }
      .skipNil()

    self.showAlert = self.changeCurrencyAlertProperty.signal.skipNil().ignoreValues()
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

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let dismissCurrencyPicker: Signal<Void, NoError>
  public let reloadData: Signal<(User, Currency), NoError>
  public let presentCurrencyPicker: Signal<Void, NoError>
  public let showAlert: Signal<(), NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>
  public let updateCurrencyFailure: Signal<String, NoError>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}

// MARK: Helpers
extension SettingsAccountViewModel {
  static func viewController(for cellType: SettingsAccountCellType) -> UIViewController? {
    switch cellType {
    case .changeEmail:
      return ChangeEmailViewController.instantiate()
    case .changePassword:
      return ChangePasswordViewController.instantiate()
    default:
      return nil
    }
  }
}
