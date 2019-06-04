import KsApi
import Library
import Prelude
import UIKit

class PledgeTableViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource: PledgeDataSource = PledgeDataSource()
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
    self.tableView.registerCellClass(PledgeRowCell.self)
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
      .observeValues { [weak self] amount, currency, delivery, shipping, isLoggedIn in
        self?.dataSource.load(
          amount: amount, currency: currency, delivery: delivery, shipping: shipping, isLoggedIn: isLoggedIn
        )
        self?.tableView.reloadData()
      }
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section < self.dataSource.numberOfSections(in: self.tableView) - 1 else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(withClass: PledgeFooterView.self)
    return footerView
  }

  internal override func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt _: IndexPath
  ) {
    if let descriptionCell = cell as? PledgeDescriptionCell {
      descriptionCell.delegate = self
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
