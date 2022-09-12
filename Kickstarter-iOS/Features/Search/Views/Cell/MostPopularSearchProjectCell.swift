import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class MostPopularSearchProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MostPopularSearchProjectCellViewModelType =
    MostPopularSearchProjectCellViewModel()

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var metadataBackgroundView: UIView!
  @IBOutlet fileprivate var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate var metadataLabel: UILabel!
  @IBOutlet fileprivate var percentFundedLabel: UILabel!
  @IBOutlet fileprivate var progressBarView: UIView!
  @IBOutlet fileprivate var progressStaticView: UIView!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectInfoOverlayView: UIView!
  @IBOutlet fileprivate var projectInfoStackView: UIStackView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var separateView: UIView!
  @IBOutlet fileprivate var statsStackView: UIStackView!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> MostPopularSearchProjectCell.lens.backgroundColor .~ .clear
      |> MostPopularSearchProjectCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
      }

    _ = self.cardView
      |> cardStyle()

    _ = self.statsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(6)

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    _ = self.projectInfoOverlayView
      |> UIView.lens.backgroundColor .~ .init(white: 1.0, alpha: 0.95)
      |> UIView.lens.layoutMargins %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .init(all: Styles.grid(6))
          : .init(all: Styles.grid(2))
      }

    _ = self.metadataBackgroundView
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_white.cgColor
      |> UIView.lens.layer.borderWidth .~ 1.0

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_white

    _ = self.percentFundedLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.projectInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title2()
          : UIFont.ksr_title1(size: 18)
      }
      |> UILabel.lens.textColor .~ UIColor.ksr_support_700
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    _ = self.separateView
      |> separatorStyle

    _ = self.progressStaticView
      |> UIView.lens.backgroundColor .~ .ksr_black
      |> UIView.lens.alpha .~ 0.15
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.progressBarView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.projectImageView.rac.ksr_imageUrl = self.viewModel.outputs.projectImageUrl
    self.projectNameLabel.rac.attributedText = self.viewModel.outputs.projectName

    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
      }
  }
}
