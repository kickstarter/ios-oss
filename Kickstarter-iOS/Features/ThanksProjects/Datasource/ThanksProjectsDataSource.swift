import KsApi
import Library
import UIKit

internal final class ThanksProjectsDataSource: ValueCellDataSource {
  internal func loadData(projects: [Project],
                         category: KsApi.Category,
                         nativeProjectCardsVariant: OptimizelyExperiment.Variant = .control) {
    let values = projects.map { (project) -> DiscoveryProjectCellRowValue in
      DiscoveryProjectCellRowValue(project: project, category: category, params: nil)
    }

    if nativeProjectCardsVariant == .variant1 {
      self.set(values: values, cellClass: DiscoveryProjectCardCell.self, inSection: 0)
    } else {
      self.set(values: values, cellClass: DiscoveryPostcardCell.self, inSection: 0)
    }

    self.appendRow(
      value: category,
      cellClass: ThanksCategoryCell.self,
      toSection: 0
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoveryPostcardCell, value as DiscoveryProjectCellRowValue):
      cell.configureWith(value: value)
    case let (cell as DiscoveryProjectCardCell, value as DiscoveryProjectCellRowValue):
      cell.configureWith(value: value)
    case let (cell as ThanksCategoryCell, value as KsApi.Category):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  internal func projectAtIndexPath(_ indexPath: IndexPath) -> Project? {
    let discoveryProjectCellRowValue = self[indexPath] as? DiscoveryProjectCellRowValue

    return discoveryProjectCellRowValue?.project
  }
}
