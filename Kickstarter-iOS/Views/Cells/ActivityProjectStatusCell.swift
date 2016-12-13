import AlamofireImage
import CoreImage
import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivityProjectStatusCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityProjectStatusViewModelType = ActivityProjectStatusViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var fundingProgressBarView: UIView!
  @IBOutlet private weak var fundingProgressContainerView: UIView!
  @IBOutlet private weak var fundingProgressLabel: UILabel!
  @IBOutlet private weak var metadataBackgroundView: UIView!
  @IBOutlet private weak var metadataLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var textBackgroundView: UIView!

  func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.metadataBackgroundColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.fundingProgressBarView.rac.backgroundColor = self.viewModel.outputs.fundingBarColor
    self.fundingProgressLabel.rac.attributedText = self.viewModel.outputs.percentFundedText

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak projectImageView] url in
        projectImageView?.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.fundingProgressPercentage
      .observeForUI()
      .observeNext { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.gridHalf(7), left: Styles.grid(30), bottom: Styles.grid(2),
                  right: Styles.grid(30))
          : .init(top: Styles.gridHalf(6), left: Styles.grid(2), bottom: Styles.gridHalf(3),
                  right: Styles.grid(2))
    }

    self.cardView
      |> dropShadowStyle()

    self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    self.metadataBackgroundView
      |> UIView.lens.layer.cornerRadius .~ 2.0
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(1))

    self.metadataLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.textColor .~ .whiteColor()

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.textBackgroundView
      |> UIView.lens.alpha .~ 0.96
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))
  }
}
