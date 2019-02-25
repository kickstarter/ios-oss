import Prelude
import ReactiveSwift
import Result
import KsApi

public protocol SettingsViewModelInputs {
  func currentUserUpdated()
  func logoutCanceled()
  func logoutConfirmed()
  func settingsCellTapped(cellType: SettingsCellType)
  func viewDidLoad()
  func viewWillAppear()
}

public protocol SettingsViewModelOutputs {
  var goToAppStoreRating: Signal<String, NoError> { get }
  var logoutWithParams: Signal<DiscoveryParams, NoError> { get }
  var reloadDataWithUser: Signal<User, NoError> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
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
      viewDidLoadProperty.signal,
      currentUserUpdatedProperty.signal)
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()

    self.reloadDataWithUser = user

    self.showConfirmLogoutPrompt = selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .logout }
      .map { _ in
        (message: Strings.profile_settings_logout_alert_message(),
         cancel: Strings.profile_settings_logout_alert_cancel_button(),
         confirm: Strings.profile_settings_logout_alert_confirm_button()
        )
    }

    self.logoutWithParams = self.logoutConfirmedProperty.signal
      .map { .defaults
        |> DiscoveryParams.lens.includePOTD .~ true
        |> DiscoveryParams.lens.sort .~ .magic
    }

    self.goToAppStoreRating = selectedCellTypeProperty.signal
      .skipNil()
      .filter { $0 == .rateInAppStore }
      .map { _ in AppEnvironment.current.config?.iTunesLink ?? "" }

    self.transitionToViewController = selectedCellTypeProperty.signal
      .skipNil()
      .map(viewControllerFactory)
      .skipNil()

    self.viewDidLoadProperty.signal.observeValues { _ in AppEnvironment.current.koala.trackSettingsView() }

    self.logoutCanceledProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackCancelLogoutModal() }

    self.logoutConfirmedProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackConfirmLogoutModal() }

    self.goToAppStoreRating
      .observeValues { _ in AppEnvironment.current.koala.trackAppStoreRatingOpen() }

    self.showConfirmLogoutPrompt
      .observeValues { _ in AppEnvironment.current.koala.trackLogoutModal() }
  }

  private var currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  private var selectedCellTypeProperty = MutableProperty<SettingsCellType?>(nil)
  public func settingsCellTapped(cellType: SettingsCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let logoutCanceledProperty = MutableProperty(())
  public func logoutCanceled() {
    self.logoutCanceledProperty.value = ()
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

  public let goToAppStoreRating: Signal<String, NoError>
  public let logoutWithParams: Signal<DiscoveryParams, NoError>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError>
  public let reloadDataWithUser: Signal<User, NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>

  public var inputs: SettingsViewModelInputs { return self }
  public var outputs: SettingsViewModelOutputs { return self }
}

// MARK: Helpers
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
