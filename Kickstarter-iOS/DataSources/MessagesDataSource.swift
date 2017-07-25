import Library
import KsApi

internal final class MessagesDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case projectBanner
    case backing
    case messages
    case emptyState
  }

  internal func emptyState(isVisible: Bool, messageToUser: String) {
    self.set(values: isVisible ? [messageToUser] : [],
             cellClass: MessagesEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal func load(project: Project) {
    self.set(values: [project],
             cellClass: ProjectBannerCell.self,
             inSection: Section.projectBanner.rawValue)
  }

  internal func load(backing: Backing, project: Project, isFromBacking: Bool) {
    self.set(values: [(backing, project, isFromBacking)],
             cellClass: BackingCell.self,
             inSection: Section.backing.rawValue)
  }

  internal func load(messages: [Message]) {
    self.set(values: messages,
             cellClass: MessageCell.self,
             inSection: Section.messages.rawValue)
  }

  internal func isProjectBanner(indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.projectBanner.rawValue
  }

  internal func isBackingInfo(indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.backing.rawValue
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectBannerCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as BackingCell, value as (Backing, Project, Bool)):
      cell.configureWith(value: value)
    case let (cell as MessageCell, value as Message):
      cell.configureWith(value: value)
    case let (cell as MessagesEmptyStateCell, value as String):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
