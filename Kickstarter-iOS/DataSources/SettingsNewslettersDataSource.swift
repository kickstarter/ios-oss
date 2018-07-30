import Library
import KsApi

internal final class SettingsNewslettersDataSource: ValueCellDataSource {

  internal enum Section: Int {
    case newsletters
  }

  internal func load(newsletters: [Newsletter], user: User) {

    let section = Section.newsletters.rawValue

    self.clearValues(section: section)

    self.appendRow(value: user,
                   cellClass: SettingsNewslettersTopCell.self,
                   toSection: section)

    newsletters.forEach { value in

      self.appendRow(value: (value, user),
                     cellClass: SettingsNewslettersCell.self,
                     toSection: section)
    }
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
