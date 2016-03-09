import class UIKit.UICollectionViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectSubpagesCell: UICollectionViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectSubpagesViewModel?>(nil)
}
