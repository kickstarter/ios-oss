import Prelude
import ReactiveSwift
import Result
import KsApi
import Library

public protocol SettingsV2ViewModelInputs {
  func logoutCanceled()
  func logoutConfirmed()
  func settingsCellTapped(cellType: SettingsCellType)
  func viewDidLoad()
}

public protocol SettingsV2ViewModelOutputs {
  var logoutWithParams: Signal<DiscoveryParams, NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
  var goToAppStoreRating: Signal<String, NoError> { get }
  var reloadData: Signal<Void, NoError> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError> { get }
}

public protocol SettingsV2ViewModelType {
  var inputs: SettingsV2ViewModelInputs { get }
  var outputs: SettingsV2ViewModelOutputs { get }

  func shouldSelectRow(for cellType: SettingsCellType) -> Bool
}

final class SettingsV2ViewModel: SettingsV2ViewModelInputs,
SettingsV2ViewModelOutputs, SettingsV2ViewModelType {

  public init() {
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
      .map { SettingsV2ViewModel.viewController(for: $0) }
      .skipNil()

    self.reloadData = self.viewDidLoadProperty.signal

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

  private var selectedCellTypeProperty = MutableProperty<SettingsCellType?>(nil)
  func settingsCellTapped(cellType: SettingsCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let logoutCanceledProperty = MutableProperty(())
  public func logoutCanceled() {
    self.logoutCanceledProperty.value = ()
  }

  fileprivate let logoutConfirmedProperty = MutableProperty(())
  func logoutConfirmed() {
    self.logoutConfirmedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
     self.viewDidLoadProperty.value = ()
  }

  public let logoutWithParams: Signal<DiscoveryParams, NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError>
  public let reloadData: Signal<Void, NoError>

  public var inputs: SettingsV2ViewModelInputs { return self }
  public var outputs: SettingsV2ViewModelOutputs { return self }
}

// MARK: Helpers
extension SettingsV2ViewModel {
  static func viewController(for cellType: SettingsCellType) -> UIViewController? {
    switch cellType {
    case .help:
      return HelpViewController.instantiate()
    case .privacy:
      return UIViewController()
    case .newsletters:
      return UIViewController()
    case .notifications:
      return UIViewController()
    default:
      return nil
    }
  }

  func shouldSelectRow(for cellType: SettingsCellType) -> Bool {
    switch cellType {
    case .appVersion:
      return false
    default:
      return true
    }
  }
}
