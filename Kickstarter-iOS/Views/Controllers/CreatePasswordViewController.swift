import Library
import Prelude
import UIKit

private enum CreatePasswordRow: CaseIterable {
  case newPassword
  case confirmNewPassword
}

extension CreatePasswordRow {
  var title: String {
    switch self {
    case .newPassword: return Strings.New_password()
    case .confirmNewPassword: return Strings.Confirm_password()
    }
  }

  var placeholder: String {
    return Strings.signup_input_fields_password()
  }
}

final class CreatePasswordViewController: UITableViewController {
  // MARK: - Accessors

  private lazy var rightBarButtonItem: UIBarButtonItem = {
    UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
      |> \.isEnabled .~ false
  }()

  // MARK: - Lifecycle

  static func instantiate() -> CreatePasswordViewController {
    return CreatePasswordViewController(style: .grouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Create_password() }

    _ = self.navigationItem
      |> \.rightBarButtonItem .~ self.rightBarButtonItem

    _ = self.tableView
      |> \.allowsSelection .~ false
      |> \.backgroundColor .~ .ksr_grey_200
      |> \.separatorInset .~ .zero

    if #available(iOS 11, *) { } else {
      let estimatedSectionFooterHeight: CGFloat = 44
      let estimatedSectionHeaderHeight: CGFloat = 100
      let estimatedRowHeight: CGFloat = 44
      let height = UITableView.automaticDimension

      _ = self.tableView
        |> \.estimatedSectionFooterHeight .~ estimatedSectionFooterHeight
        |> \.estimatedSectionHeaderHeight .~ estimatedSectionHeaderHeight
        |> \.estimatedRowHeight .~ estimatedRowHeight
        |> \.sectionFooterHeight .~ height
        |> \.sectionHeaderHeight .~ height
        |> \.rowHeight .~ height
    }

    self.tableView.registerHeaderFooterClass(SettingsGroupedHeaderView.self)
    self.tableView.registerHeaderFooterClass(SettingsGroupedFooterView.self)
    self.tableView.registerCellClass(SettingsTextInputCell.self)
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CreatePasswordRow.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = CreatePasswordRow.allCases[indexPath.row]
    let cell = tableView.dequeueReusableCell(withClass: SettingsTextInputCell.self, for: indexPath)

    guard let textInputCell = cell as? SettingsTextInputCell else { return cell }

    textInputCell.configure(with: row.title, placeholder: row.placeholder)
    return textInputCell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let className = SettingsGroupedHeaderView.self

    guard let headerView = tableView.dequeueReusableHeaderFooterView(withClass: className)
      as? SettingsGroupedHeaderView else { return nil }

    _ = headerView.label
      |> \.text %~ { _ in
        Strings.Well_ask_you_to_sign_back_into_the_Kickstarter_app_once_youve_changed_your_password()
    }

    return headerView
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let className = SettingsGroupedFooterView.self
    guard let footerView = tableView.dequeueReusableHeaderFooterView(withClass: className)
      as? SettingsGroupedFooterView else { return nil }

    _ = footerView.label
      |> \.text %~ { _ in Strings.Password_min_length_message() }

    return footerView
  }
}
