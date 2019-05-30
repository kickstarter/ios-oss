import KsApi
import Prelude
import ReactiveSwift

public protocol SettingsAccountViewModelInputs {
  func didSelectRow(cellType: SettingsAccountCellType)
  func viewWillAppear()
  func viewDidAppear()
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var fetchAccountFieldsError: Signal<Void, Never> { get }
  var reloadData: Signal<(Currency, Bool, Bool), Never> { get }
  var transitionToViewController: Signal<UIViewController, Never> { get }
  var userHasPasswordAndEmail: (Bool, String?) { get }
}

public protocol SettingsAccountViewModelType {
  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
SettingsAccountViewModelOutputs, SettingsAccountViewModelType {

  public init(_ viewControllerFactory: @escaping (SettingsAccountCellType, Currency) -> UIViewController?) {
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

    self.userHasPasswordAndEmailProperty <~ userAccountFields.values()
      .map { ($0.me.hasPassword == .some(true), $0.me.email) }

    let chosenCurrency = userAccountFields.values()
      .map { Currency(rawValue: $0.me.chosenCurrency ?? Currency.USD.rawValue) ?? Currency.USD }

    self.reloadData = Signal.combineLatest(
      chosenCurrency,
      shouldHideEmailWarning,
      shouldHideEmailPasswordSection
    )

    self.transitionToViewController = chosenCurrency
      .takePairWhen(self.selectedCellTypeProperty.signal.skipNil())
      .map { ($1, $0) }
      .map(viewControllerFactory)
      .skipNil()

    self.viewDidAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackAccountView() }
  }

  private let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
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

  fileprivate let userHasPasswordAndEmailProperty = MutableProperty<(Bool, String?)>((true, nil))
  public var userHasPasswordAndEmail: (Bool, String?) {
    return self.userHasPasswordAndEmailProperty.value
  }

  public let fetchAccountFieldsError: Signal<Void, Never>
  public let reloadData: Signal<(Currency, Bool, Bool), Never>
  public let transitionToViewController: Signal<UIViewController, Never>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}
