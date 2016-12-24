import Foundation
import Library
import KsApi

internal final class ProfileDataSource: ValueCellDataSource {
  fileprivate var user: User!

  internal enum Section: Int {
    case projects
    case emptyState
  }

  internal func emptyState(visible: Bool) {
//    self.set(values: visible ? [()] : [],
//             cellClass: ProfileEmptyStateCell.self,
//             inSection: Section.emptyState.rawValue)
  }

  internal func load(user: User) {
    self.user = user
  }

  internal func load(projects: [Project]) {
    self.set(values: projects, cellClass: ProfileProjectCell.self, inSection: Section.projects.rawValue)
  }

  internal override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProfileProjectCell, value as Project):
      cell.configureWith(value: value)
    case (is ProfileEmptyStateCell, is Void):
      return
    default:
      fatalError("Unrecognized (\(cell), \(value)) combo.")
    }
  }

  internal func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               atIndexPath indexPath: IndexPath) -> UICollectionReusableView {

    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "Header",
                                                                     for: indexPath)
    switch view {
    case let view as ProfileHeaderView:
      view.configureWith(value: self.user)
    default:
      fatalError("Unrecognized header \(view).")
    }

    view.isHidden = indexPath.section == Section.emptyState.rawValue

    return view
  }
}
