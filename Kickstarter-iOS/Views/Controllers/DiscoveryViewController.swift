import class Library.MVVMCollectionViewController
import struct Library.Environment
import struct Library.AppEnvironment
import UIKit

internal final class DiscoveryViewController: MVVMCollectionViewController {
  let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  let dataSource = DiscoveryProjectsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView?.dataSource = dataSource
    AppEnvironment.current.koala.trackDiscovery()

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.estimatedItemSize = CGSize(width: self.view.bounds.width - 32.0, height: 300.0)
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .startWithNext { [weak self] projects in
        self?.dataSource.loadData(projects)
        self?.collectionView?.reloadData()
    }
  }
}
