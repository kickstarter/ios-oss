import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleProjectCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleProjectCellViewModelType = ActivitySampleProjectCellViewModel()
  internal weak var delegate: ActivitySampleProjectCellDelegate?

  @IBOutlet fileprivate weak var activityStackView: UIStackView!
  @IBOutlet fileprivate weak var activityTitleLabel: UILabel!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var projectImageAndInfoStackView: UIStackView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectSubtitleAndTitleStackView: UIStackView!
  @IBOutlet fileprivate weak var projectSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectTitleLabel: UILabel!
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

    _ = self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    _ = self.activityStackView
      |> activitySampleStackViewStyle

    _ = self.cardView
      |> dropShadowStyle()

    _ = self.projectImageAndInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.projectSubtitleAndTitleStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.projectSubtitleLabel
      |> activitySampleProjectSubtitleLabelStyle

    _ = self.projectTitleLabel
      |> activitySampleProjectTitleLabelStyle

    _ = self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityHint = self.viewModel.outputs.cellAccessibilityHint
    self.projectSubtitleLabel.rac.text = self.viewModel.outputs.projectSubtitleText
    self.projectTitleLabel.rac.text = self.viewModel.outputs.projectTitleText

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.goToActivity()
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc fileprivate func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
