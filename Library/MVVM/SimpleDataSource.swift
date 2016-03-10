import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell
import class UIKit.UITableView
import class UIKit.UITableViewCell

/// Represents the simplest form of a data source: one that is homogenous with respect to cell views
/// and uses `SimpleViewModel` for its data.
public final class SimpleDataSource <
  Cell: UICollectionViewCell,
  Model
  where
  Cell: ViewModeledCellType,
  Cell.ViewModel == SimpleViewModel<Model>> : MVVMDataSource {

  public override init() {
  }

  public override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(Cell.self)
  }

  public func reload(models: [Model]) {
    setData(models.map(SimpleViewModel.init), cellClass: Cell.self, inSection: 0)
  }

  public override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {
    if let
      cell = cell as? Cell,
      viewModel = viewModel as? Cell.ViewModel {
        cell.viewModelProperty.value = viewModel
    }
  }

  public override func configureCell(tableCell cell: UITableViewCell, withViewModel viewModel: AnyObject) {
    if let
      cell = cell as? Cell,
      viewModel = viewModel as? Cell.ViewModel {
        cell.viewModelProperty.value = viewModel
    }
  }
}
