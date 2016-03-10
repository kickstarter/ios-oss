import class UIKit.UICollectionViewCell
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty

internal final class ProjectMainCell: UICollectionViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ProjectMainViewModel?>(nil)

  override func bindViewModel() {
    super.bindViewModel()
  }
}
