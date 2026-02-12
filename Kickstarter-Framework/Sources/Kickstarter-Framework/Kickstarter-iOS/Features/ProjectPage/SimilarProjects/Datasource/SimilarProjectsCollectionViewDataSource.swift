import Foundation
import KsApi
import Library
import UIKit

protocol SimilarProjectsCollectionViewDataSourceDelegate: AnyObject {
  func didSelectProject(_ project: ProjectCardProperties)
}

final class SimilarProjectsCollectionViewDataSource: ValueCellDataSource {
  weak var delegate: SimilarProjectsCollectionViewDataSourceDelegate?

  func load(_ values: [ProjectCardProperties], isLoading: Bool = false) {
    guard isLoading == false else {
      /// Sets `[(), ()]` in values so that two cells display to indicate that a collection is loading.
      return self.set(
        values: [(), ()],
        cellClass: SimilarProjectsLoadingCollectionViewCell.self,
        inSection: 0
      )
    }

    self.set(
      values: values,
      cellClass: SimilarProjectsCollectionViewCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SimilarProjectsLoadingCollectionViewCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as SimilarProjectsCollectionViewCell, value as ProjectCardProperties):
      cell.configureWith(value: value)
      cell.delegate = self
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}

extension SimilarProjectsCollectionViewDataSource: SimilarProjectsCollectionViewCellDelegate {
  func didSelectProject(_ project: ProjectCardProperties) {
    self.delegate?.didSelectProject(project)
  }
}
