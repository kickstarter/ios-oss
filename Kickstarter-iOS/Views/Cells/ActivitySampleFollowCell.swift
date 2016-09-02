import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleFollowCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleFollowCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySampleFollowCellViewModelType = ActivitySampleFollowCellViewModel()
  internal weak var delegate: ActivitySampleFollowCellDelegate?

  @IBOutlet private weak var activityStackView: UIStackView!
  @IBOutlet private weak var activityTitleLabel: UILabel!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var friendFollowLabel: UILabel!
  @IBOutlet private weak var friendImageAndFollowStackView: UIStackView!
  @IBOutlet private weak var friendImageView: CircleAvatarImageView!
  @IBOutlet private weak var seeAllActivityButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllActivityButton.addTarget(
      self,
      action: #selector(seeAllActivityButtonTapped),
      forControlEvents: .TouchUpInside
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ActivitySampleFollowCell.lens.contentView.layoutMargins
      .~ .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))
      |> UITableViewCell.lens.backgroundColor .~ .clearColor()

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
      .on(next: { [weak self] _ in
        self?.friendImageView.af_cancelImageRequest()
        self?.friendImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.friendImageView.af_setImageWithURL(url)
    }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.delegate?.goToActivity()
    }
  }

  internal func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc private func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
