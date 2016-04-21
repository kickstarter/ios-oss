import UIKit
import Library
import ReactiveExtensions
import ReactiveCocoa
import Models

internal final class ActivityUpdateCell: UITableViewCell, ValueCell {
  private var viewModel: ActivityUpdateViewModel!

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var updateSequenceLabel: UILabel!
  @IBOutlet weak var timestampLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.viewModel = ActivityUpdateViewModel()

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

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName.ignoreNil()
    self.updateSequenceLabel.rac.text = self.viewModel.outputs.sequenceTitle.ignoreNil()
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.titleLabel.rac.text = self.viewModel.outputs.title.ignoreNil()
    self.bodyLabel.rac.text = self.viewModel.outputs.body
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }
}
