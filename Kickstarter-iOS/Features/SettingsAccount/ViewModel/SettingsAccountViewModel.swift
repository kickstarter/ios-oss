/**
 FIXME: This VM and its tests should be moved to the Library framework and refactored to not need the
 `viewControllerFactory` passed to its initializer.
 */
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

public typealias SettingsAccountData = (
  currency: Currency,
  email: String?,
  shouldHideEmailWarning: Bool,
  shouldHideEmailPasswordSection: Bool,
  isAppleConnectedAccount: Bool
)

public protocol SettingsAccountViewModelInputs {
  func didSelectRow(cellType: SettingsAccountCellType)
  func viewWillAppear()
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var fetchAccountFieldsError: Signal<Void, Never> { get }
  var reloadData: Signal<SettingsAccountData, Never> { get }
  var transitionToViewController: Signal<UIViewController, Never> { get }

  func shouldShowCreatePasswordFooter() -> (Bool, String?)?
}

public protocol SettingsAccountViewModelType {
  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
  SettingsAccountViewModelOutputs, SettingsAccountViewModelType {
  public init(_ viewControllerFactory: @escaping (SettingsAccountCellType, Currency) -> UIViewController?) {
    let userAccountFields = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.viewWillAppearProperty.signal.skip(first: 1)
    )
    .switchMap { _ in
      AppEnvironment.current.apiService
        .fetchGraphUser(withStoredCards: false)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    self.fetchAccountFieldsError = userAccountFields.errors().ignoreValues()

    let user = userAccountFields.values().map(\.me)

    let shouldHideEmailWarning = user
      .map { user -> Bool in
        if user.isAppleConnected == .some(true) {
          return true
        }

        guard let isEmailVerified = user.isEmailVerified,
          let isDeliverable = user.isDeliverable else {
          return true
        }

        return isEmailVerified && isDeliverable
      }

    let shouldHideEmailPasswordSection = user
      .map { $0.hasPassword == .some(false) || $0.isAppleConnected == .some(true) }

    let shouldShowCreatePasswordFooter = user
      .map { user -> (Bool, String?) in
        let isAppleConnected = user.isAppleConnected == .some(true)
        let userHasPassword = user.hasPassword == .some(true)
        let shouldShow = !userHasPassword && !isAppleConnected

        return (shouldShow, user.email)
      }

    let isAppleConnectedAccount = user.map { $0.isAppleConnected == .some(true) }

    self.shouldShowCreatePasswordFooterAndEmailProperty <~ shouldShowCreatePasswordFooter

    let chosenCurrency = user
      .map { Currency(rawValue: $0.chosenCurrency ?? Currency.USD.rawValue) ?? Currency.USD }

    self.reloadData = Signal.zip(
      chosenCurrency,
      user.map(\.email),
      shouldHideEmailWarning,
      shouldHideEmailPasswordSection,
      isAppleConnectedAccount
    ).map { $0 as SettingsAccountData }

    self.transitionToViewController = chosenCurrency
      .takePairWhen(self.selectedCellTypeProperty.signal.skipNil())
      .map { ($1, $0) }
      .map(viewControllerFactory)
      .skipNil()
  }

  private let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func didSelectRow(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let shouldShowCreatePasswordFooterAndEmailProperty = MutableProperty<(Bool, String?)?>(nil)
  public func shouldShowCreatePasswordFooter() -> (Bool, String?)? {
    return self.shouldShowCreatePasswordFooterAndEmailProperty.value
  }

  public let fetchAccountFieldsError: Signal<Void, Never>
  public let reloadData: Signal<SettingsAccountData, Never>
  public let transitionToViewController: Signal<UIViewController, Never>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}
