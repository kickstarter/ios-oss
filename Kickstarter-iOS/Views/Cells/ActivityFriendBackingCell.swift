import class UIKit.UICollectionViewCell
import class UIKit.UILabel
import class UIKit.UIImageView
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~

internal final class ActivityFriendBackingCell: UICollectionViewCell, ViewModeledCellType {
  let viewModelProperty = MutableProperty<ActivityFriendBackingViewModel?>(nil)

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendTitleLabel: UILabel!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var creatorNameLabel: UILabel!
  @IBOutlet internal weak var projectImageView: UIImageView!

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.map { $0.outputs.friendImageURL }
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.friendImageView.af_cancelImageRequest()
        self?.friendImageView.image = nil
      })
      .ignoreNil()
      .startWithNext { [weak self] url in
        self?.friendImageView.af_setImageWithURL(url)
    }

    self.friendTitleLabel.rac_text <~ self.viewModel.map { $0.outputs.friendTitle }.observeForUI()
    self.projectNameLabel.rac_text <~ self.viewModel.map { $0.outputs.projectName }.observeForUI()
    self.creatorNameLabel.rac_text <~ self.viewModel.map { $0.outputs.creatorName }.observeForUI()

    self.viewModel.map { $0.outputs.projectImageURL }
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .ignoreNil()
      .startWithNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }
}
