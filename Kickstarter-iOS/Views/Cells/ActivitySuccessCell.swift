import AlamofireImage
import CoreImage
import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivitySuccessCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySuccessViewModelType = ActivitySuccessViewModel()

  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var fundedSubtitleLabel: UILabel!
  @IBOutlet private weak var pledgedTitleLabel: UILabel!
  @IBOutlet private weak var pledgedSubtitleLabel: UILabel!

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

  override func bindStyles() {
    super.bindStyles()

    self
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(10), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(4))
    }
  }
}
