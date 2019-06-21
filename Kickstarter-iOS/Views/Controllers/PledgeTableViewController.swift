import KsApi
import Library
import Prelude
import UIKit

class PledgeTableViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource: PledgeDataSource = PledgeDataSource()
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
    self.tableView.registerCellClass(PledgeSummaryCell.self)
    self.tableView.registerCellClass(PledgeShippingLocationCell.self)
    self.tableView.registerHeaderFooterClass(PledgeFooterView.self)

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

    self.viewModel.outputs.reloadWithData
      .observeForUI()
      .observeValues { [weak self] project, reward, isLoggedIn in
        self?.dataSource.load(project: project, reward: reward, isLoggedIn: isLoggedIn)
        self?.tableView.reloadData()
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
    case is PledgeDescriptionCell:
      (cell as? PledgeDescriptionCell)?.delegate = self
    case is PledgeSummaryCell:
      (cell as? PledgeSummaryCell)?.delegate = self
    case is PledgeShippingLocationCell:
      self.shippingLocationCell = (cell as? PledgeShippingLocationCell)
    default:
      break
    }
  }
}

extension PledgeTableViewController: PledgeDescriptionCellDelegate {
  internal func pledgeDescriptionCellDidPresentTrustAndSafety(_: PledgeDescriptionCell) {
    let vc = HelpWebViewController.configuredWith(helpType: .trust)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
  }
}

extension PledgeTableViewController: PledgeSummaryCellDelegate {
  internal func pledgeSummaryCell(_: PledgeSummaryCell, didOpen helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
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
