import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import KsApi
import UIKit

internal protocol ActivityUpdateCellDelegate: class {
  /// Call with the activity value when navigating to the activity's project.
  func activityUpdateCellTappedProjectImage(activity: Activity)
}

internal final class ActivityUpdateCell: UITableViewCell, ValueCell {
  fileprivate var viewModel: ActivityUpdateViewModelType = ActivityUpdateViewModel()
  internal weak var delegate: ActivityUpdateCellDelegate?

  @IBOutlet fileprivate weak var bodyLabel: UILabel!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var projectImageButton: UIButton!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var updateSequenceLabel: UILabel!

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.updateSequenceLabel.rac.attributedText = self.viewModel.outputs.sequenceTitle
    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.bodyLabel.rac.text = self.viewModel.outputs.body
    self.projectImageButton.accessibilityHint = Strings.dashboard_tout_accessibility_hint_opens_project()
    self.projectImageButton.rac.accessibilityLabel = self.viewModel.outputs.projectButtonAccessibilityLabel

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak projectImageView] url in
        projectImageView?.af_setImage(withURL: url)
    }

    self.viewModel.outputs.notifyDelegateTappedProjectImage
      .observeForUI()
      .observeValues { [weak self] activity in
        self?.delegate?.activityUpdateCellTappedProjectImage(activity: activity)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    _ = self.cardView
      |> dropShadowStyleMedium()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.bodyLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.titleLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
  }

  @IBAction internal func tappedProjectImage() {
    self.viewModel.inputs.tappedProjectImage()
  }
}
