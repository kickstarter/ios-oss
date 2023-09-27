import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletContentDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case creatorHeader
    case main
    case subpages
    case pledgeTitle
  }

  internal func loadMinimal(project: Project) {
    self.set(values: [project], cellClass: ProjectPamphletMinimalCell.self, inSection: Section.main.rawValue)

    let values = [
      ProjectPamphletSubpage.comments(project.stats.commentsCount as Int?, .first),
      ProjectPamphletSubpage.updates(project.stats.updatesCount as Int?, .last)
    ]

    self.set(
      values: values,
      cellClass: ProjectPamphletSubpageCell.self,
      inSection: Section.subpages.rawValue
    )
  }

  internal func load(data: ProjectPamphletContentData) {
    self.clearValues()

    let (project, refTag) = data

    if currentUserIsCreator(of: project) {
      self.set(
        values: [project],
        cellClass: ProjectPamphletCreatorHeaderCell.self,
        inSection: Section.creatorHeader.rawValue
      )
    }

    self.set(
      values: [(project, refTag)],
      cellClass: ProjectPamphletMainCell.self,
      inSection: Section.main.rawValue
    )

    let values: [ProjectPamphletSubpage] = [
      .comments(project.stats.commentsCount as Int?, .first),
      .updates(project.stats.updatesCount as Int?, .last)
    ]

    self.set(
      values: values,
      cellClass: ProjectPamphletSubpageCell.self,
      inSection: Section.subpages.rawValue
    )
  }

  internal func indexPathForMainCell() -> IndexPath {
    return IndexPath(item: 0, section: Section.main.rawValue)
  }

  internal func indexPathIsCommentsSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isComments == true
  }

  internal func indexPathIsUpdatesSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isUpdates == true
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectPamphletCreatorHeaderCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMainCell, value as ProjectPamphletMainCellData):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMinimalCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletSubpageCell, value as ProjectPamphletSubpage):
      cell.configureWith(value: value)
    default:
      fatalError("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
    }
  }
}
