import KsApi
import Library
import Prelude
import UIKit

private enum PledgeSection: CaseIterable {
  case project
  case inputs
  case summary
}

extension PledgeSection {
  var rows: [PledgeRow] {
    switch self {
    case .project:
      return [.description]
    case .inputs:
      return [.pledgeAmount, .shippingLocation]
    case .summary:
      return [.total]
    }
  }

  var numberOfRows: Int {
    return self.rows.count
  }
}

private enum PledgeRow: CaseIterable {
  case description
  case pledgeAmount
  case shippingLocation
  case total
}

extension PledgeRow {
  var title: String {
    switch self {
    case .description:
      return "Description"
    case .pledgeAmount:
      return "Your pledge amount"
    case .shippingLocation:
      return "Your shipping location"
    case .total:
      return "Total"
    }
  }
}

class PledgeTableViewController: UITableViewController {
  // MARK: - Properties

  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  static func instantiate() -> PledgeTableViewController {
    return PledgeTableViewController(style: .grouped)
  }

  func configure(with project: Project) {
    self.viewModel.inputs.configure(with: project)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.tableView
      |> tableViewStyle

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Footer")
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return PledgeSection.allCases.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return PledgeSection.allCases[section].numberOfRows
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = PledgeSection.allCases[indexPath.section].rows[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = row.title
    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section < PledgeSection.allCases.count - 1 else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Footer")
    return footerView
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { (tableView: UITableView) in
  tableView
    |> \.contentInset .~ UIEdgeInsets(top: -35)
    |> \.sectionFooterHeight .~ 10
    |> \.sectionHeaderHeight .~ 0
    |> \.separatorStyle .~ .none
}
