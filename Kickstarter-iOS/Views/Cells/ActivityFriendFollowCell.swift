import class UIKit.UITableViewCell
import class UIKit.UIImageView
import class UIKit.UILabel
import class UIKit.UIButton
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~

internal final class ActivityFriendFollowCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ActivityFriendFollowViewModel?>(nil)

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendLabel: UILabel!
  @IBOutlet internal weak var followButton: UIButton!

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

    self.friendLabel.rac_text <~ self.viewModel.map { $0.outputs.title }
    self.followButton.rac_hidden <~ self.viewModel.map { $0.outputs.hideFollowButton }

    self.viewModel.map { $0.outputs.title }
      .startWithNext { print($0) }
  }

  @IBAction
  internal func followButtonPressed() {
    self.viewModelProperty.value?.inputs.followButtonPressed()
  }
}
