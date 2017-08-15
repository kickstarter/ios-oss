import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleBackingCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleBackingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleBackingCellViewModelType = ActivitySampleBackingCellViewModel()
  internal weak var delegate: ActivitySampleBackingCellDelegate?

  @IBOutlet fileprivate weak var activityStackView: UIStackView!
  @IBOutlet fileprivate weak var activityTitleLabel: UILabel!
  @IBOutlet fileprivate weak var backerImageAndInfoStackView: UIStackView!
  @IBOutlet fileprivate weak var backerImageView: CircleAvatarImageView!
  @IBOutlet fileprivate weak var backingTitleLabel: UILabel!
  @IBOutlet fileprivate weak var cardView: UIView!
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

    _ = self
      |> activitySampleCellStyle
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project()
    }

    _ = self.activityStackView
      |> activitySampleStackViewStyle

    _ = self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    _ = self.backerImageAndInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.backingTitleLabel
      |> activitySampleBackingTitleLabelStyle

    _ = self.cardView
      |> dropShadowStyleMedium()

    _ = self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backerImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.backerImageView.af_cancelImageRequest()
        self?.backerImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.backerImageView.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.backingTitleText
      .observeForUI()
      .observeValues { [weak element = backingTitleLabel] attrString in
        element?.attributedText = attrString
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
