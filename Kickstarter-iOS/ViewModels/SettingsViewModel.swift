/**
 FIXME: This VM and its tests should be moved to the Library framework and refactored to not need the
 `viewControllerFactory` passed to its initializer.
 */

import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

public protocol SettingsViewModelInputs {
  func currentUserUpdated()
  func logoutConfirmed()
  func settingsCellTapped(cellType: SettingsCellType)
  func viewDidLoad()
  func viewWillAppear()
}

public protocol SettingsViewModelOutputs {
  var findFriendsDisabledProperty: MutableProperty<Bool> { get }
  var goToAppStoreRating: Signal<String, Never> { get }
  var logoutWithParams: Signal<DiscoveryParams, Never> { get }
  var reloadDataWithUser: Signal<User, Never> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), Never> { get }
  var transitionToViewController: Signal<UIViewController, Never> { get }
}

public protocol SettingsViewModelType {
  var inputs: SettingsViewModelInputs { get }
  var outputs: SettingsViewModelOutputs { get }

  func shouldSelectRow(for cellType: SettingsCellType) -> Bool
}

public final class SettingsViewModel: SettingsViewModelInputs,
  SettingsViewModelOutputs, SettingsViewModelType {
  public init(_ viewControllerFactory: @escaping (SettingsCellType) -> UIViewController?) {
    let user = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.currentUserUpdatedProperty.signal
    )
    .flatMap {
      AppEnvironment.current.apiService.fetchUserSelf()
        .wrapInOptional()
        .prefix(value: AppEnvironment.current.currentUser)
        .demoteErrors()
    }
    .skipNil()

    let isFollowingEnabled = user
      .map { $0 |> (\User.social).view }
      .map { $0 ?? true }

    self.findFriendsDisabledProperty <~ isFollowingEnabled.negate()

    self.reloadDataWithUser = Signal.zip(user, self.findFriendsDisabledProperty.signal).map(first)

    self.showConfirmLogoutPrompt = self.selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .logout }
      .map { _ in
        (
          message: Strings.profile_settings_logout_alert_message(),
          cancel: Strings.profile_settings_logout_alert_cancel_button(),
          confirm: Strings.Yes()
        )
      }

    self.logoutWithParams = self.logoutConfirmedProperty.signal
      .map { .defaults
        |> DiscoveryParams.lens.includePOTD .~ true
        |> DiscoveryParams.lens.sort .~ .magic
      }

    self.goToAppStoreRating = self.selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .rateInAppStore }
      .map { _ in AppEnvironment.current.config?.iTunesLink ?? "" }

    self.transitionToViewController = self.selectedCellTypeProperty.signal
      .skipNil()
      .map(viewControllerFactory)
      .skipNil()
  }

  private var currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  private var selectedCellTypeProperty = MutableProperty<SettingsCellType?>(nil)
  public func settingsCellTapped(cellType: SettingsCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let logoutConfirmedProperty = MutableProperty(())
  public func logoutConfirmed() {
    self.logoutConfirmedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let findFriendsDisabledProperty = MutableProperty<Bool>(false)
  public let goToAppStoreRating: Signal<String, Never>
  public let logoutWithParams: Signal<DiscoveryParams, Never>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), Never>
  public let reloadDataWithUser: Signal<User, Never>
  public let transitionToViewController: Signal<UIViewController, Never>

  public var inputs: SettingsViewModelInputs { return self }
  public var outputs: SettingsViewModelOutputs { return self }
}

// MARK: - Helpers

extension SettingsViewModel {
  public func shouldSelectRow(for cellType: SettingsCellType) -> Bool {
    switch cellType {
    case .findFriends:
      guard let user = AppEnvironment.current.currentUser else {
        return true
      }

      return (user |> User.lens.social.view) ?? true
    default:
      return true
    }
  }
}
