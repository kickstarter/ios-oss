import Library
import KsApi

internal final class MessagesDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case projectBanner
    case backing
    case messages
  }

  internal func load(project: Project) {
    // FIXME
//    self.set(values: [project],
//             cellClass: ProjectBannerCell.self,
//             inSection: Section.ProjectBanner.rawValue)
  }

  internal func load(backing: Backing, project: Project) {
    // FIXME
//    self.set(values: [(backing, project)],
//             cellClass: BackingCell.self,
//             inSection: Section.Backing.rawValue)
  }

  internal func load(messages: [Message]) {
    // FIXME
//    self.set(values: messages,
//             cellClass: MessageCell.self,
//             inSection: Section.Messages.rawValue)
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
    case let (cell as BackingCell, value as (Backing, Project)):
      cell.configureWith(value: value)
    case let (cell as MessageCell, value as Message):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
