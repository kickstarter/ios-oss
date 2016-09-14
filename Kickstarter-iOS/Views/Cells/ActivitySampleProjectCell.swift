import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleProjectCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleProjectCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySampleProjectCellViewModelType = ActivitySampleProjectCellViewModel()
  internal weak var delegate: ActivitySampleProjectCellDelegate?

  @IBOutlet private weak var activityStackView: UIStackView!
  @IBOutlet private weak var activityTitleLabel: UILabel!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var projectImageAndInfoStackView: UIStackView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectSubtitleAndTitleStackView: UIStackView!
  @IBOutlet private weak var projectSubtitleLabel: UILabel!
  @IBOutlet private weak var projectTitleLabel: UILabel!
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
      |> ActivitySampleProjectCell.lens.contentView.layoutMargins
      .~ .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))
      |> UITableViewCell.lens.backgroundColor .~ .clearColor()
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project()
    }

    self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    self.activityStackView
      |> activitySampleStackViewStyle

    self.cardView
      |> dropShadowStyle()

    self.projectImageAndInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectSubtitleAndTitleStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    self.projectSubtitleLabel
      |> activitySampleProjectSubtitleLabelStyle

    self.projectTitleLabel
      |> activitySampleProjectTitleLabelStyle

    self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.projectSubtitleLabel.rac.text = self.viewModel.outputs.projectSubtitleText
    self.projectTitleLabel.rac.text = self.viewModel.outputs.projectTitleText

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.delegate?.goToActivity()
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  internal func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc private func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
