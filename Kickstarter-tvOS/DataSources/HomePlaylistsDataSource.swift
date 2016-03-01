import Models
import KsApi

final class HomePlaylistsDataSource : MVVMDataSource {


  func load(viewModels: [HomePlaylistViewModel]) {
    self.setData(viewModels,
      cellClass: HomePlaylistCell.self,
      inSection: 0
    )
  }

  override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(HomePlaylistCell.self)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {
    if let cell = cell as? HomePlaylistCell,
      viewModel = viewModel as? HomePlaylistViewModel {
        cell.viewModel.value = viewModel
    }
  }
}
