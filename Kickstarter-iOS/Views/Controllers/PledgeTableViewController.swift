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
      .observeValues { [weak self] (amount, currency, delivery, isLoggedIn) in
        self?.dataSource.load(amount: amount, currency: currency, delivery: delivery, isLoggedIn: isLoggedIn)

        self?.tableView.reloadData()
    }
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section < self.dataSource.numberOfSections(in: self.tableView) - 1 else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(withClass: PledgeFooterView.self)
    return footerView
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

  if #available(iOS 11, *) { } else {
    let estimatedHeight: CGFloat = 44

    return style
      |> \.contentInset .~ UIEdgeInsets(top: 30)
      |> \.estimatedSectionFooterHeight .~ estimatedHeight
      |> \.estimatedSectionHeaderHeight .~ estimatedHeight
      |> \.estimatedRowHeight .~ estimatedHeight
      |> \.rowHeight .~ UITableView.automaticDimension
  }

  return style
}
