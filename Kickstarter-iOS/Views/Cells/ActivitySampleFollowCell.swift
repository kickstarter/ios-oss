import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySampleFollowCellDelegate: AnyObject {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleFollowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleFollowCellViewModelType = ActivitySampleFollowCellViewModel()
  internal weak var delegate: ActivitySampleFollowCellDelegate?

  @IBOutlet fileprivate var activityStackView: UIStackView!
  @IBOutlet fileprivate var activityTitleLabel: UILabel!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var friendFollowLabel: UILabel!
  @IBOutlet fileprivate var friendImageAndFollowStackView: UIStackView!
  @IBOutlet fileprivate var friendImageView: CircleAvatarImageView!
  @IBOutlet fileprivate var seeAllActivityButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllActivityButton.addTarget(
      self,
      action: #selector(self.seeAllActivityButtonTapped),
      for: .touchUpInside
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> activitySampleCellStyle
      |> \.backgroundColor .~ discoveryPageBackgroundColor()

    _ = self.activityStackView
      |> activitySampleStackViewStyle

    _ = self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    _ = self.cardView
      |> dropShadowStyleMedium()

    _ = self.friendFollowLabel
      |> activitySampleFriendFollowLabelStyle

    _ = self.friendImageAndFollowStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.friendImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.friendFollowLabel.rac.text = self.viewModel.outputs.friendFollowText

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.friendImageView.af.cancelImageRequest()
        self?.friendImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.friendImageView.af.setImage(withURL: url)
      }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.goToActivity()
      }
  }

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc fileprivate func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
