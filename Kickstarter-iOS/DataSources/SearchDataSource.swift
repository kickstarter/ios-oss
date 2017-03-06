import KsApi
import Library
import Prelude
import UIKit

internal final class SearchDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case popularTitle
    case projects
    case noResults
    case loading
  }

  internal func popularTitle(isVisible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["MostPopularCell"] : [],
             inSection: Section.popularTitle.rawValue)
  }

  internal func loader(isVisible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["SearchLoadingStateCell"] : [],
             inSection: Section.loading.rawValue)
  }

  internal func load(params: DiscoveryParams, visible: Bool) {
    self.set(values: visible ? [params] : [],
             cellClass: SearchEmptyStateCell.self,
             inSection: Section.noResults.rawValue)
  }

  internal func load(projects: [Project]) {
    self.clearValues(section: Section.projects.rawValue)

    if let mostPopular = projects.first {
      self.appendRow(value: mostPopular,
                     cellClass: MostPopularSearchProjectCell.self,
                     toSection: Section.projects.rawValue)
    }

    if !projects.isEmpty {
      projects.suffix(from: 1).forEach {
        self.appendRow(value: $0, cellClass: SearchProjectCell.self, toSection: Section.projects.rawValue)
      }
    }
  }

  internal func indexPath(forProjectRow row: Int) -> IndexPath {
    return IndexPath(item: row, section: Section.projects.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SearchProjectCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as MostPopularSearchProjectCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as MostPopularCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as SearchEmptyStateCell, value as DiscoveryParams):
      cell.configureWith(value: value)
    case let (cell as SearchLoadingStateCell, value as Void):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
