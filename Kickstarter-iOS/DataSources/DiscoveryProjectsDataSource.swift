import class Library.MVVMDataSource
import struct Models.Project
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell

internal final class DiscoveryProjectsDataSource: MVVMDataSource {

  func loadData(projects: [Project]) {
    self.setData(
      projects.map { DiscoveryProjectViewModel(project: $0) },
      cellClass: DiscoveryProjectCell.self,
      inSection: 0)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {
    if let cell = cell as? DiscoveryProjectCell,
      viewModel = viewModel as? DiscoveryProjectViewModel {
        cell.viewModelProperty.value = viewModel
    }
  }
}
