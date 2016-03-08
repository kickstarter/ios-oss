import class UIKit.UICollectionViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectRewardCell: UICollectionViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectRewardViewModel?>(nil)
}
