import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var friendImageView: UIImageView!
  @IBOutlet fileprivate var friendLabel: UILabel!
  @IBOutlet fileprivate var followButton: UIButton!

  func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton
    self.friendLabel.rac.attributedText = self.viewModel.outputs.title

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(event: { [weak friendImageView] _ in
        friendImageView?.af.cancelImageRequest()
        friendImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak friendImageView] url in
        friendImageView?.ksr_setImageWithURL(url)
      }
  }

  override func bindStyles() { super.bindStyles() }

  @objc fileprivate func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }
}
