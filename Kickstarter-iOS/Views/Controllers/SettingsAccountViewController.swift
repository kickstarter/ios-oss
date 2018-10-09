import KsApi
import Library
import Prelude
import ReactiveSwift
import Result
import UIKit

final class SettingsAccountViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView!

  private let dataSource = SettingsAccountDataSource()
  fileprivate let viewModel: SettingsAccountViewModelType = SettingsAccountViewModel()

  internal static func instantiate() -> SettingsAccountViewController {
    return Storyboard.SettingsAccount.instantiate(SettingsAccountViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self

    self.tableView.register(nib: .SettingsTableViewCell)
    self.tableView.register(nib: .SettingsCurrencyPickerCell)

    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.configureRows()
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentCurrencyPicker
      .observeForUI()
      .observeValues { [weak self] show in
        self?.showCurrencyPickerCell(show)
    }

    self.viewModel.outputs.dismissCurrencyPicker
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismissCurrencyPickerCell()
    }

    self.viewModel.outputs.transitionToViewController
      .observeForControllerAction()
      .observeValues { [weak self] (viewController) in
        self?.navigationController?.pushViewController(viewController, animated: true)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in Strings.Account() }

    _ = tableView
      |> settingsTableViewStyle
  }

  func showCurrencyPickerCell(_ show: Bool) {
    if show {
      self.tableView.beginUpdates()
      self.tableView.insertRows(at: [self.dataSource.insertCurrencyPickerRow()], with: .top)
      let tapRecognizer = UITapGestureRecognizer(target: self,
                                                 action: #selector(tapGestureToDismissCurrencyPicker))
      tapRecognizer.cancelsTouchesInView = false
      self.view.addGestureRecognizer(tapRecognizer)
      self.tableView.endUpdates()
    }
  }

  func dismissCurrencyPickerCell() {
    tableView.beginUpdates()
    self.tableView.deleteRows(at: [self.dataSource.removeCurrencyPickerRow()], with: .top)
    tableView.endUpdates()

    self.view.gestureRecognizers?.removeAll()
  }

  @objc private func tapGestureToDismissCurrencyPicker() {
    self.viewModel.inputs.dismissPickerTap()
  }
}

extension SettingsAccountViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }
    self.viewModel.inputs.didSelectRow(cellType: cellType)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove the footer in UITableViewStyleGrouped
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? SettingsCurrencyPickerCell {
      cell.delegate = self
    }
  }
}

extension SettingsAccountViewController: SettingsCurrencyPickerCellDelegate {
  internal func shouldDismissCurrencyPicker() {
    self.dismissCurrencyPickerCell()
  }
}
