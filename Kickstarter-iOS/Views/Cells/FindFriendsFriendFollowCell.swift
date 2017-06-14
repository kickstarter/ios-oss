import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class FindFriendsFriendFollowCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var avatarImageView: CircleAvatarImageView!
  @IBOutlet fileprivate weak var friendNameLabel: UILabel!
  @IBOutlet fileprivate weak var friendLocationLabel: UILabel!
  @IBOutlet fileprivate weak var projectsBackedLabel: UILabel!
  @IBOutlet fileprivate weak var projectsCreatedLabel: UILabel!
  @IBOutlet fileprivate weak var followButton: UIButton!
  @IBOutlet fileprivate weak var unfollowButton: UIButton!

  fileprivate let viewModel: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()

  func configureWith(value: (friend: User, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(friend: value.friend, source: value.source)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.followButton.rac.enabled = self.viewModel.outputs.enableFollowButton
    self.followButton.rac.accessibilityLabel = self.viewModel.outputs.followButtonAccessibilityLabel

    self.unfollowButton.rac.enabled = self.viewModel.outputs.enableUnfollowButton
    self.unfollowButton.rac.accessibilityLabel = self.viewModel.outputs.unfollowButtonAccessibilityLabel

    self.friendNameLabel.rac.text = self.viewModel.outputs.name

    self.friendLocationLabel.rac.text = self.viewModel.outputs.location

    self.projectsBackedLabel.rac.text = self.viewModel.outputs.projectsBackedText

    self.projectsCreatedLabel.rac.text = self.viewModel.outputs.projectsCreatedText

    self.projectsCreatedLabel.rac.hidden = self.viewModel.outputs.hideProjectsCreated

    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton

    self.unfollowButton.rac.hidden = self.viewModel.outputs.hideUnfollowButton

    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(event: { [weak avatarImageView] _ in
        avatarImageView?.af_cancelImageRequest()
        avatarImageView?.image = nil
        })
      .skipNil()
      .observeValues { [weak avatarImageView] url in
        avatarImageView?.ksr_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.friendNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14.0)

    _ = self.self.friendLocationLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ .ksr_caption1()

    _ = self.projectsBackedLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_footnote()

    _ = self.projectsCreatedLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_footnote()

    _ = self.followButton
      |> navyButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.targets .~ [(self, action: #selector(followButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.social_following_friend_buttons_follow() }

    _ = self.unfollowButton
      |> lightNavyButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_navy_600
      |> UIButton.lens.targets .~ [(self, action: #selector(unfollowButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(forState: .normal) %~ { _ in
        Strings.social_following_friend_buttons_following()
    }

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .white
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
