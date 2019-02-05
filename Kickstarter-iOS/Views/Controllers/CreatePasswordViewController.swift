import Prelude
import UIKit

private struct ReuseIdentifier {
  static let cell = "SettingsInputCell"
  static let header = "SettingsHeaderView"
}

private enum CreatePasswordRow: CaseIterable {
  case newPassword
  case confirmNewPassword
}

extension CreatePasswordRow {
  var title: String {
    switch self {
    case .newPassword: return "New password"
    case .confirmNewPassword: return "Confirm new password"
    }
  }

  var placeholder: String {
    return "Password"
  }
}

class CreatePasswordViewController: UITableViewController {
  // MARK: - Accessors

  private lazy var rightBarButtonItem: UIBarButtonItem = {
    return UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
      |> \.isEnabled .~ false
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "Create Password"

    _ = self.navigationItem
      |> \.rightBarButtonItem .~ self.rightBarButtonItem

    _ = self.tableView
      |> \.allowsSelection .~ false
      |> \.separatorInset .~ .zero

    if #available(iOS 11, *) { } else {
      let headerHeight: CGFloat = 100

      _ = self.tableView
        |> \.sectionHeaderHeight .~ headerHeight
        |> \.estimatedSectionHeaderHeight .~ headerHeight
    }

    self.tableView.register(
      SettingsGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifier.header
    )
    self.tableView.register(SettingsTextInputCell.self, forCellReuseIdentifier: ReuseIdentifier.cell)
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CreatePasswordRow.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = CreatePasswordRow.allCases[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.cell, for: indexPath)

    guard let textInputCell = cell as? SettingsTextInputCell else { return cell }

    textInputCell.configure(with: row.title, placeholder: row.placeholder)
    return textInputCell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifier.header)
      as? SettingsGroupedHeaderView else { return nil }

    let text = "We'll ask you to sign back into the Kickstarter app once you've changed your password."
    headerView.label.text = text
    return headerView
  }
}
