import class UIKit.UITableViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectRewardCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectRewardViewModel?>(nil)
}
