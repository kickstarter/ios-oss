import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var friendImageView: UIImageView!
  @IBOutlet private weak var friendLabel: UILabel!
  @IBOutlet private weak var followButton: UIButton!

  func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.followButton.rac.hidden = self.viewModel.outputs.hideFollowButton
    self.friendLabel.rac.attributedText = self.viewModel.outputs.title

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(next: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak friendImageView] url in
        friendImageView?.ksr_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> feedTableViewCellStyle

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    self.friendLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.followButton
      |> navyButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.social_following_friend_buttons_follow() }
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3),
                                                  leftRight: Styles.gridHalf(5))
  }

  @objc private func followButtonTapped() {
    self.viewModel.inputs.followButtonTapped()
  }
}
