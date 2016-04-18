import UIKit
import Library
import ReactiveCocoa
import AlamofireImage
import CoreImage
import Models

internal final class ActivityStateChangeCell: UITableViewCell, ValueCell {
  private var viewModel: ActivityStateChangeViewModel!

  @IBOutlet internal weak var projectImageView: UIImageView!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var fundedSubtitleLabel: UILabel!
  @IBOutlet internal weak var pledgedTitleLabel: UILabel!
  @IBOutlet internal weak var pledgedSubtitleLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.viewModel = ActivityStateChangeViewModel()

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

    self.viewModel.outputs.fundingDate
      .observeForUI()
      .observeNext { [weak fundedSubtitleLabel] date in
        fundedSubtitleLabel?.text = date
    }

    self.viewModel.outputs.pledgedTitle
      .observeForUI()
      .observeNext { [weak pledgedTitleLabel] title in
        pledgedTitleLabel?.text = title
    }

    self.viewModel.outputs.pledgedSubtitle
      .observeForUI()
      .observeNext { [weak pledgedSubtitleLabel] title in
        pledgedSubtitleLabel?.text = title
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }
}
