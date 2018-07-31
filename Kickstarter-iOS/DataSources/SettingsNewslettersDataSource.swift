import Library
import KsApi

internal final class SettingsNewslettersDataSource: ValueCellDataSource {

  internal enum Section: Int {
    case newsletters
  }

  internal func load(newsletters: [Newsletter], user: User) {

    let section = Section.newsletters.rawValue

    let values = newsletters.map { ($0, user) }

    self.set(values: values, cellClass: SettingsNewslettersCell.self, inSection: section)
    self.set(value: user, cellClass: SettingsNewslettersTopCell.self, inSection: section, row: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsNewslettersTopCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsNewslettersCell, value as (newsletter: Newsletter, user: User)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
