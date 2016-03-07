import Prelude
import class Library.MVVMDataSource

final class PlaylistTrayDataSource : MVVMDataSource {

  override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(PlaylistTrayCell.self)
  }

  func load(viewModels: [PlaylistsMenuViewModel]) {
    for (idx, viewModel) in viewModels.enumerate() {
      appendRowData(viewModel, cellClass: PlaylistTrayCell.self, toSection: idx)
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {

    if let cell = cell as? PlaylistTrayCell,
      viewModel = viewModel as? PlaylistsMenuViewModel {
        cell.viewModelProperty.value = viewModel
    }
  }
}
