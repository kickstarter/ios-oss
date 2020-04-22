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

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle

    _ = self.cardView
      |> cardStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    _ = self.friendImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.friendLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.followButton
      |> blackButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(self.followButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.social_following_friend_buttons_follow() }
  }

  @objc fileprivate func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }
}
