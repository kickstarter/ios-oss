import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var friendImageView: UIImageView!
  @IBOutlet fileprivate weak var friendLabel: UILabel!
  @IBOutlet fileprivate weak var followButton: UIButton!

  func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton
    self.friendLabel.rac.attributedText = self.viewModel.outputs.title

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(event: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
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
      |> dropShadowStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    _ = self.friendLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500

    _ = self.followButton
      |> navyButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.social_following_friend_buttons_follow() }
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3),
                                                  leftRight: Styles.gridHalf(5))
  }

  @objc fileprivate func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }
}
