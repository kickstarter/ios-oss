import KsApi
import Library
import Prelude
import UIKit

typealias TitleRow = Void

internal final class SearchDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case projects
    case noResults
  }

  internal func load(params: DiscoveryParams, visible: Bool) {
    self.set(
      values: visible ? [params] : [],
      cellClass: SearchEmptyStateCell.self,
      inSection: Section.noResults.rawValue
    )
  }

  internal func load(
    projects: [any BackerDashboardProjectCellViewModel.ProjectCellModel],
    withDiscoverTitle showTitle: Bool
  ) {
    self.clearValues(section: Section.projects.rawValue)

    if projects.count > 0 && showTitle {
      self.appendRow(
        value: TitleRow(),
        cellClass: DiscoverProjectsTitleCell.self,
        toSection: Section.projects.rawValue
      )
    }

    if let mostPopular = projects.first {
      self.appendRow(
        value: mostPopular,
        cellClass: MostPopularSearchProjectCell.self,
        toSection: Section.projects.rawValue
      )
    }

    if !projects.isEmpty {
      projects.dropFirst().forEach {
        self.appendRow(
          value: $0,
          cellClass: BackerDashboardProjectCell.self,
          toSection: Section.projects.rawValue
        )
      }
    }
  }

  func indexOfProject(forCellAtIndexPath indexPath: IndexPath) -> Int? {
    if indexPath.section != Section.projects.rawValue {
      // Not the projects section
      return nil
    }

    if self.numberOfItems(in: Section.projects.rawValue) == 0 {
      // Projects are empty
      return nil
    }

    let firstIndex = IndexPath(row: 0, section: Section.projects.rawValue)
    let value = self[firstIndex]
    let hasTitleRow = value is TitleRow

    if hasTitleRow {
      // If there's a title row, the index of the actual project is one item less.
      return indexPath.row - 1
    } else {
      return indexPath.row
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (
      cell as BackerDashboardProjectCell,
      value as any BackerDashboardProjectCellViewModel.ProjectCellModel
    ):
      cell.configureWith(value: value)
    case let (
      cell as MostPopularSearchProjectCell,
      value as any BackerDashboardProjectCellViewModel.ProjectCellModel
    ):
      cell.configureWith(value: value)
    case let (cell as DiscoverProjectsTitleCell, value as TitleRow):
      cell.configureWith(value: value)
    case let (cell as SearchEmptyStateCell, value as DiscoveryParams):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
