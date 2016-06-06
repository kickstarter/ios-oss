import UIKit
import Library
import ReactiveCocoa
import KsApi

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendFollowViewModel = ActivityFriendFollowViewModel()

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendLabel: UILabel!
  @IBOutlet internal weak var followButton: UIButton!

  override func bindViewModel() {
    self.friendLabel.rac.text = self.viewModel.outputs.title
    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(next: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak friendImageView] url in
        friendImageView?.af_setImageWithURL(url)
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }

  @IBAction
  internal func followButtonPressed() {
    self.viewModel.inputs.followButtonPressed()
  }
}
