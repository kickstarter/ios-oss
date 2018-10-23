import UIKit
import KsApi
import Library

public struct PaymentMethodsCellValue {
  let user: User?
  let cellType: SettingsCellTypeProtocol
}

final class PaymentMethodsDataSource: ValueCellDataSource {

  private enum Section: Int {
    case creditCards
  }

  internal func load(newsletters: [Newsletter], user: User) {

    let section = Section.creditCards.rawValue

    self.clearValues(section: section)

    self.appendRow(value: user, cellClass: SettingsNewslettersTopCell.self, toSection: section)

    _ = newsletters.map { ($0, user) }.map { value in
      self.appendRow(value: value, cellClass: SettingsNewslettersCell.self, toSection: section)
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
