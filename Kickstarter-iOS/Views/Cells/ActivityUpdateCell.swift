import Library
import Prelude
import ReactiveExtensions
import ReactiveCocoa
import KsApi
import UIKit

protocol ActivityUpdateCellDelegate {
  /// Call with the activity value when navigating to the activity's project.
  func activityUpdateCellTappedProjectImage(activity activity: Activity)
}

internal final class ActivityUpdateCell: UITableViewCell, ValueCell {
  private var viewModel: ActivityUpdateViewModelType = ActivityUpdateViewModel()
  internal var delegate: ActivityUpdateCellDelegate?

  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var projectImageButton: UIButton!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var updateSequenceLabel: UILabel!

  internal func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  internal override func bindViewModel() {
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.updateSequenceLabel.rac.attributedText = self.viewModel.outputs.sequenceTitle
    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.bodyLabel.rac.text = self.viewModel.outputs.body
    self.projectImageButton.accessibilityHint = Strings.dashboard_tout_accessibility_hint_opens_project()
    self.projectImageButton.rac.accessibilityLabel = self.viewModel.outputs.projectButtonAccessibilityLabel

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak projectImageView] url in
        projectImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.notifyDelegateTappedProjectImage
      .observeForUI()
      .observeNext { [weak self] activity in
        self?.delegate?.activityUpdateCellTappedProjectImage(activity: activity)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(10), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(2))
    }

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.bodyLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.titleLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
  }

  @IBAction internal func tappedProjectImage() {
    self.viewModel.inputs.tappedProjectImage()
  }
}
