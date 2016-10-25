import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal protocol FindFriendsFriendFollowCellDelegate: class {
  func findFriendsFriendFollowCell(cell: FindFriendsFriendFollowCell, updatedFriend: User)
}

internal final class FindFriendsFriendFollowCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var avatarImageView: CircleAvatarImageView!
  @IBOutlet private weak var friendNameLabel: UILabel!
  @IBOutlet private weak var friendLocationLabel: UILabel!
  @IBOutlet private weak var projectsBackedLabel: UILabel!
  @IBOutlet private weak var projectsCreatedLabel: UILabel!
  @IBOutlet private weak var followButton: UIButton!
  @IBOutlet private weak var unfollowButton: UIButton!

  private let viewModel: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()

  internal weak var delegate: FindFriendsFriendFollowCellDelegate?

  func configureWith(value value: (friend: User, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(friend: value.friend, source: value.source)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.followButton.rac.enabled = self.viewModel.outputs.enableFollowButton

    self.unfollowButton.rac.enabled = self.viewModel.outputs.enableUnfollowButton

    self.friendNameLabel.rac.text = self.viewModel.outputs.name

    self.friendLocationLabel.rac.text = self.viewModel.outputs.location

    self.projectsBackedLabel.rac.text = self.viewModel.outputs.projectsBackedText

    self.projectsCreatedLabel.rac.text = self.viewModel.outputs.projectsCreatedText

    self.projectsCreatedLabel.rac.hidden = self.viewModel.outputs.hideProjectsCreated

    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton

    self.unfollowButton.rac.hidden = self.viewModel.outputs.hideUnfollowButton

    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(next: { [weak avatarImageView] _ in
        avatarImageView?.af_cancelImageRequest()
        avatarImageView?.image = nil
        })
      .ignoreNil()
      .observeNext { [weak avatarImageView] url in
        avatarImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.2))
    }

    self.viewModel.outputs.notifyDelegateFriendUpdated
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.findFriendsFriendFollowCell(_self, updatedFriend: $0)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self.friendNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14.0)

    self.self.friendLocationLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ .ksr_caption1()

    self.projectsBackedLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_footnote()

    self.projectsCreatedLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_footnote()

    self.followButton
      |> navyButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.social_following_friend_buttons_follow() }

    self.unfollowButton
      |> lightNavyButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(unfollowButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.social_following_friend_buttons_following()
    }

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(2))
    }
  }

  @objc func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }

  @objc func unfollowButtonTapped() {
    self.viewModel.inputs.unfollowButtonTapped()
  }
}
