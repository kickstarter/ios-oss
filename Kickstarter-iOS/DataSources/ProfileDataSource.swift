import Foundation
import Library
import KsApi

internal final class ProfileDataSource: ValueCellDataSource {
  private var user: User!

  internal enum Section: Int {
    case projects
    case emptyState
  }

  internal func emptyState(visible visible: Bool) {
//    self.set(values: visible ? [()] : [],
//             cellClass: ProfileEmptyStateCell.self,
//             inSection: Section.emptyState.rawValue)
  }

  internal func load(user user: User) {
    self.user = user
  }

  internal func load(projects projects: [Project]) {
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

  internal func collectionView(collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

    let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                     withReuseIdentifier: "Header",
                                                                     forIndexPath: indexPath)
    switch view {
    case let view as ProfileHeaderView:
      view.configureWith(value: self.user)
    default:
      fatalError("Unrecognized header \(view).")
    }

    view.hidden = indexPath.section == Section.emptyState.rawValue

    return view
  }
}
