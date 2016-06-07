import KsApi
import Library

final class HomePlaylistsDataSource: ValueCellDataSource {

  func load(values: [Playlist]) {
    self.set(values: values,
             cellClass: HomePlaylistCell.self,
             inSection: 0)
  }

  override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(HomePlaylistCell.self)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {

    if let cell = cell as? HomePlaylistCell, value = value as? Playlist {
      cell.configureWith(value: value)
    }
  }
}
