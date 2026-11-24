import KsApi
import Library
import Prelude
import ReactiveSwift
import SwiftUI
import UIKit

final class SettingsAccountViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet private var tableView: UITableView!

  private let dataSource = SettingsAccountDataSource()
  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate let viewModel: SettingsAccountViewModelType = SettingsAccountViewModel(
    SettingsAccountViewController.viewController(for:currency:)
  )

  internal static func instantiate() -> SettingsAccountViewController {
    return Storyboard.Settings.instantiate(SettingsAccountViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.estimatedSectionFooterHeight = SettingsGroupedFooterView.defaultHeight

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.tableView.register(nib: .SettingsTableViewCell)
    self.tableView.register(nib: .SettingsAccountWarningCell)
    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)
    self.tableView.registerHeaderFooterClass(SettingsGroupedFooterView.self)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  override func bindViewModel() {
    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] currency, email, isAppleConnectedAccount in
        self?.dataSource.configureRows(
          currency: currency,
          isAppleConnected: isAppleConnectedAccount
        )

        if let email = email, isAppleConnectedAccount {
          self?.showAppleHeader(with: email)
        }

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.fetchAccountFieldsError
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.configureRows(
          currency: nil,
          isAppleConnected: false
        )

        self?.tableView.reloadData()

        self?.showGeneralError()
      }

    self.viewModel.outputs.transitionToViewController
      .observeForControllerAction()
      .observeValues { [weak self] viewController in
        self?.navigationController?.pushViewController(viewController, animated: true)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in Strings.Account() }

    _ = self.tableView
      |> settingsTableViewStyle
      |> settingsTableViewSeparatorStyle
  }

  // MARK: - Functions

  private func showGeneralError() {
    self.messageBannerViewController?.showBanner(
      with: .error,
      message: Strings.Something_went_wrong_please_try_again()
    )
  }

  private func showAppleHeader(with appleId: String) {
    let container = UIView(frame: .zero)

    self.tableView.tableHeaderView = container

    let header = SettingsAccountHeaderView(frame: .zero)
    header.configure(with: appleId)

    _ = (header, container)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = header.widthAnchor.constraint(equalTo: self.tableView.widthAnchor)
      |> \.priority .~ .defaultHigh
      |> \.isActive .~ true
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

  func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
    return SettingsSectionType.sectionHeaderHeight
  }

  func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
    return nil
  }
}

extension SettingsAccountViewController {
  static func viewController(for cellType: SettingsAccountCellType, currency: Currency) -> UIViewController? {
    switch cellType {
    case .paymentMethods:
      return PaymentMethodSettingsViewController.instantiate()
    case .privacy:
      return SettingsPrivacyViewController.instantiate()
    case .currency:
      let vc = SelectCurrencyViewController.instantiate()
      vc.configure(with: currency)
      return vc
    }
  }
}
