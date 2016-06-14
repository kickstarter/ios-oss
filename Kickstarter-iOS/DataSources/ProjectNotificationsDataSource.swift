import Library
import KsApi
import UIKit

internal final class ProjectNotificationsDataSource: ValueCellDataSource {
  internal func load(notifications notifications: [ProjectNotification]) {
    self.set(values: notifications,
             cellClass: ProjectNotificationCell.self,
             inSection: 0)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectNotificationCell, value as ProjectNotification):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }
}
