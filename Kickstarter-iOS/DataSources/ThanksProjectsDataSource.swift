import UIKit
import KsApi
import Library

internal final class ThanksProjectsDataSource: ValueCellDataSource {
  internal func loadData(projects projects: [Project], category: KsApi.Category) {

    self.set(values: projects, cellClass: ThanksProjectCell.self, inSection: 0)

    self.appendRow(
      value: category,
      cellClass: ThanksCategoryCell.self,
      toSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ThanksProjectCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ThanksCategoryCell, value as KsApi.Category):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  internal func projectAtIndexPath(indexPath: NSIndexPath) -> Project? {
    return self[indexPath] as? Project
  }

  internal func categoryAtIndexPath(indexPath: NSIndexPath) -> KsApi.Category? {
    return self[indexPath] as? KsApi.Category
  }
}
