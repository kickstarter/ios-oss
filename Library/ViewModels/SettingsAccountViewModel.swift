import Prelude
import ReactiveSwift
import Result
import KsApi

public protocol SettingsAccountViewModelInputs {
  func settingsCellTapped(cellType: SettingsAccountCellType)
  func didSelectRow(cellType: SettingsAccountCellType)
  func viewDidLoad()
}

public protocol SettingsAccountViewModelOutputs {
  var reloadData: Signal<Void, NoError> { get }
  var showCurrencyPicker: Signal<Void, NoError> { get }
  var transitionToViewController: Signal<UIViewController, NoError> { get }
}

public protocol SettingsAccountViewModelType {

  var inputs: SettingsAccountViewModelInputs { get }
  var outputs: SettingsAccountViewModelOutputs { get }
}

public final class SettingsAccountViewModel: SettingsAccountViewModelInputs,
SettingsAccountViewModelOutputs, SettingsAccountViewModelType {

  public init() {
    self.reloadData = self.viewDidLoadProperty.signal

    let currencyCellSelected = self.selectedCellType.signal
      .skipNil()
      .filter {  $0 == .currency }

    self.showCurrencyPicker =
      currencyCellSelected.signal.mapConst(true).ignoreValues()

    self.transitionToViewController = self.selectedCellTypeProperty.signal
      .skipNil()
      .map { SettingsAccountViewModel.viewController(for: $0) }
      .skipNil()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let selectedCellTypeProperty = MutableProperty<SettingsAccountCellType?>(nil)
  public func settingsCellTapped(cellType: SettingsAccountCellType) {
    self.selectedCellTypeProperty.value = cellType
  }

  fileprivate let selectedCellType = MutableProperty<SettingsAccountCellType?>(nil)
  public func didSelectRow(cellType: SettingsAccountCellType) {
    self.selectedCellType.value = cellType
  }

  public let reloadData: Signal<Void, NoError>
  public let showCurrencyPicker: Signal<Void, NoError>
  public let transitionToViewController: Signal<UIViewController, NoError>

  public var inputs: SettingsAccountViewModelInputs { return self }
  public var outputs: SettingsAccountViewModelOutputs { return self }
}

// MARK: Helpers
extension SettingsAccountViewModel {
  static func viewController(for cellType: SettingsAccountCellType) -> UIViewController? {
    return nil
  }
}
