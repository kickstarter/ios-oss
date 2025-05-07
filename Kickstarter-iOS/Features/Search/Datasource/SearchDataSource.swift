import KsApi
import Library
import UIKit

private typealias TitleRow = Void

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

  internal func load(results: SearchResults) {
    self.clearValues(section: Section.projects.rawValue)

    guard results.projects.count > 0 else {
      // The screen is loading. Projects were cleared.
      return
    }

    // Add either the discover title, or the number of results,
    // before the project cards
    if results.isProjectsTitleVisible {
      self.appendRow(
        value: TitleRow(),
        cellClass: DiscoverProjectsTitleCell.self,
        toSection: Section.projects.rawValue
      )
    } else {
      self.appendRow(
        value: results.count,
        cellClass: SearchResultsCountCell.self,
        toSection: Section.projects.rawValue
      )
    }

    guard let mostPopular = results.projects.first else {
      return
    }

    // First result card should be displayed extra large
    self.appendRow(
      value: mostPopular,
      cellClass: MostPopularSearchProjectCell.self,
      toSection: Section.projects.rawValue
    )

    results.projects.dropFirst().forEach {
      self.appendRow(
        value: $0,
        cellClass: BackerDashboardProjectCell.self,
        toSection: Section.projects.rawValue
      )
    }
  }

  func indexOfProject(forCellAtIndexPath indexPath: IndexPath) -> Int? {
    if indexPath.section != Section.projects.rawValue {
      // Not the projects section
      return nil
    }

    let projectsSectionCount = self.numberOfItems(in: Section.projects.rawValue)

    if projectsSectionCount == 0 {
      // Projects are empty
      return nil
    }

    guard indexPath.row < projectsSectionCount else {
      // Out of bounds
      return nil
    }

    let firstIndex = IndexPath(row: 0, section: Section.projects.rawValue)
    let value = self[firstIndex]
    let firstRowIsProject = value is BackerDashboardProjectCellViewModel.ProjectCellModel
    let hasTitleRow = !firstRowIsProject

    if hasTitleRow && indexPath == firstIndex {
      // Tapping on the title row does nothing.
      return nil
    }

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
    case let (cell as SearchResultsCountCell, value as Int):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
