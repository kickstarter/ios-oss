import AlamofireImage
import CoreImage
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ActivityProjectStatusCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivityProjectStatusViewModelType = ActivityProjectStatusViewModel()

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var fundingProgressBarView: UIView!
  @IBOutlet fileprivate var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate var fundingProgressLabel: UILabel!
  @IBOutlet fileprivate var metadataBackgroundView: UIView!
  @IBOutlet fileprivate var metadataLabel: UILabel!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var textBackgroundView: UIView!

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.metadataBackgroundColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.fundingProgressBarView.rac.backgroundColor = self.viewModel.outputs.fundingBarColor
    self.fundingProgressLabel.rac.attributedText = self.viewModel.outputs.percentFundedText

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak projectImageView] _ in
        projectImageView?.af.cancelImageRequest()
        projectImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak projectImageView] url in
        projectImageView?.ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.fundingProgressPercentage
      .observeForUI()
      .observeValues { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransform(scaleX: CGFloat(progress), y: 1.0)
      }
  }

  internal override func bindStyles() {
    super.bindStyles()
  }
}
