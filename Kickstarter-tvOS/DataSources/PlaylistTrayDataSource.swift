import Prelude
import class Library.ValueCellDataSource

final class PlaylistTrayDataSource: ValueCellDataSource {

  override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(PlaylistTrayCell.self)
  }

  func load(values: [Playlist]) {
    for (idx, value) in values.enumerate() {
      appendRow(value: value, cellClass: PlaylistTrayCell.self, toSection: idx)
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {

    if let cell = cell as? PlaylistTrayCell, value = value as? Playlist {
      cell.configureWith(value: value)
    }
  }
}
