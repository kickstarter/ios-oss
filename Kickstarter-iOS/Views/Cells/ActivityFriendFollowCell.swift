import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal protocol ActivityFriendFollowCellDelegate: class {
  func activityFriendFollowCell(cell: ActivityFriendFollowCell, updatedActivity: Activity)
}

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()

  @IBOutlet private weak var friendImageView: UIImageView!
  @IBOutlet private weak var friendLabel: UILabel!
  @IBOutlet private weak var followButton: UIButton!

  internal weak var delegate: ActivityFriendFollowCellDelegate?

  func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

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
        friendImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.2))
    }

    self.viewModel.outputs.notifyDelegateFriendUpdated
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.activityFriendFollowCell(_self, updatedActivity: $0)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> UITableViewCell.lens.selectionStyle .~ .None

    self.followButton
      |> greenButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.social_following_friend_buttons_follow() }
  }

  @objc private func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }
}
