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

    self.tableView.register(PledgeRowCell.self, forCellReuseIdentifier: "PledgeRowCell")
    self.tableView.register(PledgeAmountCell.self, forCellReuseIdentifier: "PledgeAmountCell")
    self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Footer")

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

    self.viewModel.outputs.amountAndCurrency
      .observeForUI()
      .observeValues { [weak self] (amount, currency) in
        self?.dataSource.load(amount: amount, currency: currency)
        self?.tableView.reloadData()
    }
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section < self.dataSource.numberOfSections(in: self.tableView) - 1 else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Footer")
    return footerView
  }
}

// MARK: - Styles

private func tableViewStyle(_ tableView: UITableView) -> UITableView {
  let style = tableView
    |> \.allowsSelection .~ false
    |> \.separatorStyle .~ UITableViewCell.SeparatorStyle.none
    |> \.contentInset .~ UIEdgeInsets(top: -35)
    |> \.sectionFooterHeight .~ 10
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
