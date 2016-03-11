import class UIKit.UITableViewCell
import class Library.MVVMDataSource

internal final class ProjectDataSource: MVVMDataSource {

  internal func loadData() {
    self.clearData()

    self.appendRowData(
      ProjectMainViewModel(),
      cellClass: ProjectMainCell.self,
      toSection: 0
    )
    self.appendRowData(
      ProjectSubpagesViewModel(),
      cellClass: ProjectSubpagesCell.self,
      toSection: 0
    )
    self.appendRowData(
      ProjectRewardViewModel(),
      cellClass: ProjectRewardCell.self,
      toSection: 0
    )
    self.appendRowData(
      ProjectRewardViewModel(),
      cellClass: ProjectRewardCell.self,
      toSection: 0
    )
    self.appendRowData(
      ProjectRewardViewModel(),
      cellClass: ProjectRewardCell.self,
      toSection: 0
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withViewModel viewModel: AnyObject) {

    switch (cell, viewModel) {
    case let (cell as ProjectMainCell, viewModel as ProjectMainViewModel):
      cell.viewModelProperty.value = viewModel
    case let (cell as ProjectSubpagesCell, viewModel as ProjectSubpagesViewModel):
      cell.viewModelProperty.value = viewModel
    case let (cell as ProjectRewardCell, viewModel as ProjectRewardViewModel):
      cell.viewModelProperty.value = viewModel
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(viewModel.dynamicType)) combo.")
    }
  }
}
