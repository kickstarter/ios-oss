import Foundation
import Library
import KsApi

internal final class ProfileDataSource: ValueCellDataSource {
  fileprivate var user: User!

  internal enum Section: Int {
    case projects
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

    return view
  }

  internal func indexPath(for itemPosition: Int) -> IndexPath {
    return IndexPath(item: itemPosition, section: Section.projects.rawValue)
  }
}
