import class UIKit.UITableViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectSubpagesCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectSubpagesViewModel?>(nil)
}
