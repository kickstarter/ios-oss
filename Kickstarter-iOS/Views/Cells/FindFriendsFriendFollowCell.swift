import UIKit
import Library
import ReactiveCocoa
import KsApi

internal final class FindFriendsFriendFollowCell: UITableViewCell, ValueCell {

  @IBOutlet weak var avatarImageView: CircleAvatarImageView!
  @IBOutlet weak var friendNameLabel: StyledLabel!
  @IBOutlet weak var friendLocationLabel: StyledLabel!
  @IBOutlet weak var projectsBackedLabel: StyledLabel!
  @IBOutlet weak var projectsCreatedLabel: StyledLabel!
  @IBOutlet weak var followButton: BorderButton!
  @IBOutlet weak var unfollowButton: BorderButton!

  private let viewModel: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()

  override func bindViewModel() {
    super.bindViewModel()

    self.followButton.rac.enabled = self.viewModel.outputs.enableFollowButton

    self.unfollowButton.rac.enabled = self.viewModel.outputs.enableUnfollowButton

    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(next: { [weak avatarImageView] _ in
        avatarImageView?.af_cancelImageRequest()
        avatarImageView?.image = nil
        })
      .ignoreNil()
      .observeNext { [weak avatarImageView] url in
        avatarImageView?.af_setImageWithURL(url)
    }

    self.friendNameLabel.rac.text = self.viewModel.outputs.name

    self.friendLocationLabel.rac.text = self.viewModel.outputs.location

    self.projectsBackedLabel.rac.text = self.viewModel.outputs.projectsBackedText

    self.projectsCreatedLabel.rac.text = self.viewModel.outputs.projectsCreatedText

    self.projectsCreatedLabel.rac.hidden = self.viewModel.outputs.hideProjectsCreated

    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton

    self.unfollowButton.rac.hidden = self.viewModel.outputs.hideUnfollowButton
  }

  func configureWith(value value: (friend: User, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(friend: value.friend, source: value.source)
  }

  @IBAction func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }

  @IBAction func unfollowButtonTapped() {
    self.viewModel.inputs.unfollowButtonTapped()
  }
}
