import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class MostPopularSearchProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SearchProjectCellViewModelType = SearchProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var statsStackView: UIStackView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectInfoOverlayView: UIView!
  @IBOutlet fileprivate weak var projectInfoStackView: UIStackView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var separateView: UIView!

  @IBOutlet fileprivate weak var progressStaticView: UIView!
  @IBOutlet fileprivate weak var progressBarView: UIView!
  @IBOutlet fileprivate weak var percentFundedLabel: UILabel!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var metadataIconImageView: UIImageView!

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
      |> dropShadowStyleLarge()

    _ = self.statsStackView |> UIStackView.lens.spacing .~ Styles.grid(1)

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
      |> dropShadowStyleLarge()
      |> UIView.lens.layer.shadowColor .~ UIColor.black.cgColor
      |> UIView.lens.layer.shadowOpacity .~ 0.3
      |> UIView.lens.layer.cornerRadius .~ 2.0

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .white

    _ = self.projectInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title2()
          : UIFont.ksr_title1(size: 18)
      }
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    _ = self.separateView
      |> separatorStyle

    _ = self.progressStaticView
      |> UIView.lens.backgroundColor .~ .black
      |> UIView.lens.alpha .~ 0.15
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.projectImageUrlFull

    self.progressBarView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText

    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
    }

  }
}
