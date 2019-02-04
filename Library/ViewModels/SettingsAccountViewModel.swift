import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsAccountViewModelInputs {
  func didSelectRow(cellType: SettingsAccountCellType)
  func viewWillAppear()
  func viewDidAppear()
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var fetchAccountFieldsError: Signal<Void, NoError> { get }
  var reloadData: Signal<(Currency, Bool, Bool), NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
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

    let shouldHideEmailPasswordSection = userAccountFields.values()
      .map { $0.me.hasPassword == .some(false) }

    let chosenCurrency = userAccountFields.values()
      .map { Currency(rawValue: $0.me.chosenCurrency ?? Currency.USD.rawValue) ?? Currency.USD }

    self.reloadData = Signal.combineLatest(
      chosenCurrency,
      shouldHideEmailWarning,
      shouldHideEmailPasswordSection
    )

    self.transitionToViewController = self.selectedCellTypeProperty.signal.skipNil()
      .map(viewControllerFactory)
      .skipNil()

    self.viewDidAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackAccountView() }
  }

  fileprivate let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func didSelectRow(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let fetchAccountFieldsError: Signal<Void, NoError>
  public let reloadData: Signal<(Currency, Bool, Bool), NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}
