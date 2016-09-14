import Library
import KsApi

internal final class MessagesDataSource: ValueCellDataSource {
  private enum Section: Int {
    case ProjectBanner
    case Backing
    case Messages
  }

  internal func load(project project: Project) {
    self.set(values: [project],
             cellClass: ProjectBannerCell.self,
             inSection: Section.ProjectBanner.rawValue)
  }

  internal func load(backing backing: Backing, project: Project) {
    self.set(values: [(backing, project)],
             cellClass: BackingCell.self,
             inSection: Section.Backing.rawValue)
  }

  internal func load(messages messages: [Message]) {
    self.set(values: messages,
             cellClass: MessageCell.self,
             inSection: Section.Messages.rawValue)
  }

  internal func isProjectBanner(indexPath indexPath: NSIndexPath) -> Bool {
    return indexPath.section == Section.ProjectBanner.rawValue
  }

  internal func isBackingInfo(indexPath indexPath: NSIndexPath) -> Bool {
    return indexPath.section == Section.Backing.rawValue
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
