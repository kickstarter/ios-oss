import UIKit
import Library
import ReactiveExtensions
import ReactiveCocoa
import KsApi

protocol ActivityUpdateCellDelegate {
  func activityUpdateCellTappedProjectImage(activity activity: Activity)
}

internal final class ActivityUpdateCell: UITableViewCell, ValueCell {
  private var viewModel: ActivityUpdateViewModel = ActivityUpdateViewModel()

  internal var delegate: ActivityUpdateCellDelegate?

  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var projectImageButton: UIButton!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var timestampLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var updateSequenceLabel: UILabel!

  override func bindViewModel() {
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

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName.ignoreNil()
    self.updateSequenceLabel.rac.text = self.viewModel.outputs.sequenceTitle.ignoreNil()
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.titleLabel.rac.text = self.viewModel.outputs.title.ignoreNil()
    self.bodyLabel.rac.text = self.viewModel.outputs.body

    self.projectImageButton.rac.accessibilityLabel = self.viewModel.outputs.projectButtonAccessibilityLabel
    self.projectImageButton.rac.accessibilityValue = self.viewModel.outputs.projectButtonAccessibilityValue

    self.viewModel.outputs.tappedActivityProjectImage
      .observeForUI()
      .observeNext { [weak self] activity in
        self?.delegate?.activityUpdateCellTappedProjectImage(activity: activity)
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }

  @IBAction internal func tappedProjectImage() {
    self.viewModel.inputs.tappedProjectImage()
  }
}
