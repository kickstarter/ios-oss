import Foundation
import Library
import KsApi

internal final class SettingsPrivacyDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case following
    case recommendations
    case downloadData
    case deleteAccount
  }

  internal func load(user: User) {
    let this = [user]
    self.set(values: this.map { $0 } ,
               cellClass: SettingsPrivacyCell.self,
               inSection: Section.following.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsPrivacyCell, value as User):
      cell.configureWith(value: value)
    default:
      fatalError("Unrecognized combo (\(cell), \(value)).")
    }
  }
}
