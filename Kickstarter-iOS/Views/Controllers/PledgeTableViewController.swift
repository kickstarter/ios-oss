import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Sheet {
    static let offset: CGFloat = 222
  }
}

class PledgeTableViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource: PledgeDataSource = PledgeDataSource()
  private weak var pledgeSummaryCell: PledgeSummaryCell?
  private weak var shippingLocationCell: PledgeShippingLocationCell?
  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  static func instantiate() -> PledgeTableViewController {
    return PledgeTableViewController(style: .grouped)
  }

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project: project, reward: reward)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.tableView
      |> \.dataSource .~ self.dataSource

    self.tableView.registerCellClass(PledgeAmountCell.self)
    self.tableView.registerCellClass(PledgeContinueCell.self)
    self.tableView.registerCellClass(PledgeDescriptionCell.self)
    self.tableView.registerCellClass(PledgePaymentMethodsCell.self)
    self.tableView.registerCellClass(PledgeSummaryCell.self)
    self.tableView.registerCellClass(PledgeShippingLocationCell.self)
    self.tableView.registerHeaderFooterClass(PledgeFooterView.self)

    // Rebase Rebase Rebase
    self.tableView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(PledgeTableViewController.dismissKeyboard))
    )

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> tableViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.pledgeViewDataAndReload
      .observeForUI()
      .observeValues { [weak self] data, reload in
        self?.dataSource.load(data: data)

        if reload {
          self?.tableView.reloadData()
        }
      }

    self.viewModel.outputs.presentShippingRules
      .observeForUI()
      .observeValues { [weak self] project, shippingRules, selectedShippingRule in
        self?.presentShippingRules(
          project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
        )
      }

    self.viewModel.outputs.configureShippingLocationCellWithData
      .observeForUI()
      .observeValues { [weak self] isLoading, project, selectedShippingRule in
        self?.shippingLocationCell?.configureWith(
          value: (isLoading: isLoading, project: project, selectedShippingRule: selectedShippingRule)
        )
      }

    self.viewModel.outputs.configureSummaryCellWithData
      .observeForUI()
      .observeValues { [weak self] project, pledgeTotal in
        self?.pledgeSummaryCell?.configureWith(value: (project, pledgeTotal))
      }

    self.viewModel.outputs.dismissShippingRules
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section < self.dataSource.numberOfSections(in: self.tableView) - 1 else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(withClass: PledgeFooterView.self)
    return footerView
  }

  internal override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
    switch cell {
    case is PledgeAmountCell:
      (cell as? PledgeAmountCell)?.delegate = self
    case is PledgeDescriptionCell:
      (cell as? PledgeDescriptionCell)?.delegate = self
    case is PledgeSummaryCell:
      let pledgeSummaryCell = (cell as? PledgeSummaryCell)
      pledgeSummaryCell?.delegate = self
      self.pledgeSummaryCell = pledgeSummaryCell
    case is PledgeShippingLocationCell:
      let shippingLocationCell = (cell as? PledgeShippingLocationCell)
      shippingLocationCell?.delegate = self
      self.shippingLocationCell = shippingLocationCell
    default:
      break
    }
  }

  // MARK: - Actions

  @objc func dismissKeyboard() {
    self.tableView.endEditing(true)
  }

  @objc func dismissShippingRules() {
    self.viewModel.inputs.dismissShippingRulesButtonTapped()
  }

  private func presentHelpWebViewController(with helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    self.present(nc, animated: true)
  }

  private func presentShippingRules(
    _ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule
  ) {
    let vc = ShippingRulesTableViewController.instantiate()
      |> \.navigationItem.leftBarButtonItem .~ UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(PledgeTableViewController.dismissShippingRules)
      )
    vc.configureWith(project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule)

    let nc = UINavigationController(rootViewController: vc)
    let sheetVC = SheetOverlayViewController(child: nc, offset: Layout.Sheet.offset)
    self.present(sheetVC, animated: true)
  }
}

extension PledgeTableViewController: PledgeDescriptionCellDelegate {
  internal func pledgeDescriptionCellDidPresentTrustAndSafety(_: PledgeDescriptionCell) {
    self.presentHelpWebViewController(with: .trust)
  }
}

extension PledgeTableViewController: PledgeAmountCellDelegate {
  func pledgeAmountCell(_: PledgeAmountCell, didUpdateAmount amount: Double) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
  }
}

extension PledgeTableViewController: PledgeShippingLocationCellDelegate {
  func pledgeShippingCellWillPresentShippingRules(
    _: PledgeShippingLocationCell,
    selectedShippingRule rule: ShippingRule
  ) {
    self.viewModel.inputs.pledgeShippingCellWillPresentShippingRules(with: rule)
  }
}

extension PledgeTableViewController: PledgeSummaryCellDelegate {
  internal func pledgeSummaryCell(_: PledgeSummaryCell, didOpen helpType: HelpType) {
    self.presentHelpWebViewController(with: helpType)
  }
}

// MARK: - Styles

private func tableViewStyle(_ tableView: UITableView) -> UITableView {
  let style = tableView
    |> \.allowsSelection .~ false
    |> \.separatorStyle .~ UITableViewCell.SeparatorStyle.none
    |> \.contentInset .~ UIEdgeInsets(top: -35)
    |> \.sectionFooterHeight .~ PledgeFooterView.defaultHeight
    |> \.sectionHeaderHeight .~ 0

  return style
}
