import class Library.MVVMDataSource
import struct Models.Project
import class UIKit.UITableViewCell

internal final class DiscoveryProjectsDataSource: MVVMDataSource {

  func loadData(projects: [Project]) {
    self.clearData()

    projects.map { DiscoveryProjectViewModel(project: $0) }
      .forEach { viewModel in
        self.appendSectionData(
          [viewModel],
          cellClass: DiscoveryProjectCell.self
        )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withViewModel viewModel: AnyObject) {
    if let cell = cell as? DiscoveryProjectCell,
      viewModel = viewModel as? DiscoveryProjectViewModel {
        cell.viewModelProperty.value = viewModel
    }
  }
}
