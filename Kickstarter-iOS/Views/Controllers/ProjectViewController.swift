import class Library.MVVMCollectionViewController
import class UIKit.UICollectionViewFlowLayout
import struct UIKit.CGSize

internal final class ProjectViewController: MVVMCollectionViewController {
  private let dataSource = ProjectDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource.loadData()
    self.collectionView?.dataSource = dataSource

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.estimatedItemSize = CGSize(width: 375.0, height: 100.0)
    }
  }
}
