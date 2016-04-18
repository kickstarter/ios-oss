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

    self.viewModel.outputs.projectName
      .observeForUI()
      .observeNext { [weak projectNameLabel] name in
        projectNameLabel?.text = name
    }

    self.viewModel.outputs.sequenceTitle
      .observeForUI()
      .observeNext { [weak updateSequenceLabel] sequence in
        updateSequenceLabel?.text = sequence
    }

    self.viewModel.outputs.timestamp
      .observeForUI()
      .observeNext { [weak timestampLabel] timestamp in
        timestampLabel?.text = timestamp
    }

    self.viewModel.outputs.title
      .observeForUI()
      .observeNext { [weak titleLabel] title in
        titleLabel?.text = title
    }

    self.viewModel.outputs.body
      .observeForUI()
      .observeNext { [weak bodyLabel] body in
        bodyLabel?.text = body
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }
}
