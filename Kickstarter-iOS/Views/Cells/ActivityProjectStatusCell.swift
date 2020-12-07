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

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(
            top: Styles.gridHalf(7), left: Styles.grid(30), bottom: Styles.grid(2),
            right: Styles.grid(30)
          )
          : .init(
            top: Styles.gridHalf(6), left: Styles.grid(2), bottom: Styles.gridHalf(3),
            right: Styles.grid(2)
          )
      }

    _ = self.containerView
      |> cardStyle()

    _ = self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_support_300

    _ = self.metadataBackgroundView
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_white.cgColor
      |> UIView.lens.layer.borderWidth .~ 1.0
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(1))

    _ = self.metadataLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.textColor .~ .ksr_white

    _ = self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 18)
      |> UILabel.lens.textColor .~ .ksr_support_700

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.textBackgroundView
      |> UIView.lens.alpha .~ 0.96
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))
  }
}
