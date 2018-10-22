import Prelude
import ReactiveSwift
import Result
import KsApi
import Library

public protocol SettingsAccountViewModelInputs {

  func settingsCellTapped(cellType: SettingsAccountCellType)
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {

  var reloadData: Signal<Void, NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
  var goToAddCard: Signal<Void, NoError> { get }
}

public protocol SettingsAccountViewModelType {

  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
SettingsAccountViewModelOutputs, SettingsAccountViewModelType {

  public init() {

    self.reloadData = self.viewDidLoadProperty.signal

    self.transitionToViewController = self.selectedCellTypeProperty.signal
      .skipNil()
      .map { SettingsAccountViewModel.viewController(for: $0) }
      .skipNil()

    self.goToAddCard = self.selectedCellTypeProperty.signal.skipNil()
      .filter { $0 == .paymentMethods }
      .ignoreValues()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func settingsCellTapped(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  public let reloadData: Signal<Void, NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>
  public let goToAddCard: Signal<Void, NoError>

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
