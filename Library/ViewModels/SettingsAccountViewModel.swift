import Prelude
import ReactiveSwift
import Result
import KsApi
import Library

public protocol SettingsAccountViewModelInputs {
  func didConfirmChangeCurrency(currency: Currency)
  func didSelectRow(cellType: SettingsAccountCellType)
  func dismissPickerTap()
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var dismissCurrencyPicker: Signal<Void, NoError> { get }
  var reloadData: Signal<Void, NoError> { get }
  var presentCurrencyPicker: Signal<Bool, NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
  var updateCurrency: Signal<(), NoError> { get }
}

public protocol SettingsAccountViewModelType {
  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
SettingsAccountViewModelOutputs, SettingsAccountViewModelType {

  public init() {
    self.reloadData = self.viewDidLoadProperty.signal

    let currencyCellSelected = self.selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .currency }

    let changeCurrencyEvent = self.didConfirmChangeCurrencyProperty.signal.skipNil()
      .map { ChangeCurrencyInput(chosenCurrency: $0.descriptionText) }
      .switchMap { AppEnvironment.current.apiService.changeCurrency(input: $0).materialize() }

    self.updateCurrency = changeCurrencyEvent.values()

    self.presentCurrencyPicker = currencyCellSelected.signal.mapConst(true)

    self.dismissCurrencyPicker = self.dismissPickerTapProperty.signal

    self.transitionToViewController = self.selectedCellTypeProperty.signal.skipNil()
      .map { SettingsAccountViewModel.viewController(for: $0) }
      .skipNil()
  }

  fileprivate let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func didSelectRow(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let dismissPickerTapProperty = MutableProperty(())
  public func dismissPickerTap() {
    self.dismissPickerTapProperty.value = ()
  }

  fileprivate let didConfirmChangeCurrencyProperty = MutableProperty<Currency?>(nil)
  public func didConfirmChangeCurrency(currency: Currency) {
    self.didConfirmChangeCurrencyProperty.value = currency
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let dismissCurrencyPicker: Signal<Void, NoError>
  public let reloadData: Signal<Void, NoError>
  public let presentCurrencyPicker: Signal<Bool, NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>
  public let updateCurrency: Signal<(), NoError>

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
