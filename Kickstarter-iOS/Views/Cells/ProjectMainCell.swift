import class UIKit.UITableViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectMainCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectMainViewModel?>(nil)

  override func bindViewModel() {
    super.bindViewModel()
  }
}
