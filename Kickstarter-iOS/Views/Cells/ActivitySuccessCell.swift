import UIKit
import Library
import ReactiveCocoa
import AlamofireImage
import CoreImage
import KsApi

internal final class ActivitySuccessCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySuccessViewModelType = ActivitySuccessViewModel()

  @IBOutlet internal weak var projectImageView: UIImageView!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var fundedSubtitleLabel: UILabel!
  @IBOutlet internal weak var pledgedTitleLabel: UILabel!
  @IBOutlet internal weak var pledgedSubtitleLabel: UILabel!

  override func bindViewModel() {
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.fundedSubtitleLabel.rac.text = self.viewModel.outputs.fundingDate
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedTitle
    self.pledgedSubtitleLabel.rac.text = self.viewModel.outputs.pledgedSubtitle

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
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }
}
