import Library
import KsApi
import Prelude
import UIKit

internal protocol ActivitySampleBackingCellDelegate: class {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleBackingCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySampleBackingCellViewModelType = ActivitySampleBackingCellViewModel()
  internal weak var delegate: ActivitySampleBackingCellDelegate?

  @IBOutlet private weak var activityStackView: UIStackView!
  @IBOutlet private weak var activityTitleLabel: UILabel!
  @IBOutlet private weak var backerImageAndInfoStackView: UIStackView!
  @IBOutlet private weak var backerImageView: CircleAvatarImageView!
  @IBOutlet private weak var backingTitleLabel: UILabel!
  @IBOutlet private weak var cardView: UIView!
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
      |> ActivitySampleBackingCell.lens.contentView.layoutMargins
      .~ .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))
      |> UITableViewCell.lens.backgroundColor .~ .clearColor()
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project()
    }

    self.activityStackView
      |> activitySampleStackViewStyle

    self.activityTitleLabel
      |> activitySampleTitleLabelStyle

    self.backerImageAndInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.backingTitleLabel
      |> activitySampleBackingTitleLabelStyle

    self.cardView
      |> dropShadowStyle()

    self.seeAllActivityButton
      |> activitySampleSeeAllActivityButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backerImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.backerImageView.af_cancelImageRequest()
        self?.backerImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.backerImageView.af_setImageWithURL(url)
    }

    self.viewModel.outputs.backingTitleText
      .observeForUI()
      .observeNext { [weak element = backingTitleLabel] attrString in
        element?.attributedText = attrString
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
