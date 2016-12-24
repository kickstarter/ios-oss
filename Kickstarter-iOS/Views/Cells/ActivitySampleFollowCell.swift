import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleFollowCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleFollowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleFollowCellViewModelType = ActivitySampleFollowCellViewModel()
  internal weak var delegate: ActivitySampleFollowCellDelegate?

  @IBOutlet fileprivate weak var activityStackView: UIStackView!
  @IBOutlet fileprivate weak var activityTitleLabel: UILabel!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var friendFollowLabel: UILabel!
  @IBOutlet fileprivate weak var friendImageAndFollowStackView: UIStackView!
  @IBOutlet fileprivate weak var friendImageView: CircleAvatarImageView!
  @IBOutlet fileprivate weak var seeAllActivityButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllActivityButton.addTarget(
      self,
      action: #selector(seeAllActivityButtonTapped),
      for: .touchUpInside
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> activitySampleCellStyle

    self.activityStackView
      |> activitySampleStackViewStyle

    self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    self.cardView
      |> dropShadowStyle()

    self.friendFollowLabel
      |> activitySampleFriendFollowLabelStyle

    self.friendImageAndFollowStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.friendFollowLabel.rac.text = self.viewModel.outputs.friendFollowText

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.friendImageView.af_cancelImageRequest()
        self?.friendImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.friendImageView.af_setImageWithURL(url)
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
