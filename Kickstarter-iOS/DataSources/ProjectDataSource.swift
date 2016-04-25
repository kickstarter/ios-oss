import UIKit
import Library
import Models

internal final class ProjectDataSource: ValueCellDataSource {

  internal func loadProject(project: Project) {
    self.clearValues()

    self.appendRow(
      value: project,
      cellClass: ProjectMainCell.self,
      toSection: 0
    )
    self.appendRow(
      value: project,
      cellClass: ProjectSubpagesCell.self,
      toSection: 0
    )

    (project.rewards ?? [])
      .filter { !$0.isNoReward }
      .sort()
      .map { (project, $0) }
      .forEach { value in
        self.appendSection(values: [value], cellClass: ProjectRewardCell.self)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectMainCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectSubpagesCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectRewardCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }
}
