import KsApi
import Library
import Prelude
import UIKit

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

    self.viewModel.outputs.configureSummaryCellWithProjectAndPledgeTotal
      .observeValues { [weak self] project, pledgeTotal in
        self?.pledgeSummaryCell?.configureWith(value: (project, pledgeTotal))
      }
  }

  // MARK: - Actions

  @objc func dismissKeyboard() {
    self.tableView.endEditing(true)
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

  private func presentHelpWebViewController(with helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
  }
}

extension PledgeTableViewController: PledgeDescriptionCellDelegate {
  internal func pledgeDescriptionCellDidPresentTrustAndSafety(_: PledgeDescriptionCell) {
    self.presentHelpWebViewController(with: .trust)
  }
}

extension PledgeTableViewController: PledgeSummaryCellDelegate {
  internal func pledgeSummaryCell(_: PledgeSummaryCell, didOpen helpType: HelpType) {
    self.presentHelpWebViewController(with: helpType)
  }
}

extension PledgeTableViewController: PledgeShippingLocationCellDelegate {
  func pledgeShippingCell(_: PledgeShippingLocationCell, didSelectShippingRule rule: ShippingRule) {
    self.viewModel.inputs.shippingRuleDidUpdate(to: rule)
  }
}

extension PledgeTableViewController: PledgeAmountCellDelegate {
  func pledgeAmountCell(_: PledgeAmountCell, didUpdateAmount amount: Double) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
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
