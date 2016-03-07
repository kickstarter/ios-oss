import class Library.MVVMCollectionViewController
import UIKit

final internal class ActivitiesViewController: MVVMCollectionViewController {
  let viewModel: ActivitiesViewModelType = ActivitiesViewModel()
  let dataSource = ActivitiesDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView?.dataSource = dataSource

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.estimatedItemSize = CGSize(width: 375.0, height: 300.0)
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .startWithNext { [weak self] activities in
        self?.dataSource.loadData(activities)
        self?.collectionView?.reloadData()
    }
  }
}
