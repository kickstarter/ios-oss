import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySampleProjectCellDelegate: AnyObject {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleProjectCellViewModelType = ActivitySampleProjectCellViewModel()
  internal weak var delegate: ActivitySampleProjectCellDelegate?

  @IBOutlet fileprivate var activityStackView: UIStackView!
  @IBOutlet fileprivate var activityTitleLabel: UILabel!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var projectImageAndInfoStackView: UIStackView!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectSubtitleAndTitleStackView: UIStackView!
  @IBOutlet fileprivate var projectSubtitleLabel: UILabel!
  @IBOutlet fileprivate var projectTitleLabel: UILabel!
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

    _ = self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    _ = self.activityStackView
      |> activitySampleStackViewStyle

    _ = self.cardView
      |> dropShadowStyleMedium()

    _ = self.projectImageAndInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.projectSubtitleAndTitleStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

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
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }
  }

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc fileprivate func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
