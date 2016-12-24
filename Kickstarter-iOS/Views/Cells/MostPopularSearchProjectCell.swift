import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class MostPopularSearchProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MostPopularSearchProjectCellViewModelType = MostPopularSearchProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var fundingLabel: UILabel!
  @IBOutlet fileprivate weak var fundingProgressBarView: UIView!
  @IBOutlet fileprivate weak var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate weak var fundingStackView: UIStackView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectInfoOverlayView: UIView!
  @IBOutlet fileprivate weak var projectInfoStackView: UIStackView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var separateView: UIView!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> MostPopularSearchProjectCell.lens.backgroundColor .~ .clear
      |> MostPopularSearchProjectCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    self.cardView
      |> dropShadowStyle()

    self.fundingLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    self.fundingProgressBarView
      |> UIView.lens.backgroundColor .~ .ksr_green_400

    self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_500

    self.fundingStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectInfoOverlayView
      |> UIView.lens.backgroundColor .~ .init(white: 1.0, alpha: 0.95)
      |> UIView.lens.layoutMargins %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .init(all: Styles.grid(6))
          : .init(all: Styles.grid(2))
    }

    self.projectInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title2()
          : UIFont.ksr_title1(size: 18)
      }
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    self.separateView
      |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.fundingLabel.rac.text = self.viewModel.outputs.fundingLabelText

    self.viewModel.outputs.fundingProgress
      .observeForUI()
      .observeValues { [weak self] in
        let anchorX = $0 == 0 ? 0 : 0.5 / $0
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransform(scaleX: CGFloat($0), y: 1.0)
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.image = nil
        self?.projectImageView.af_cancelImageRequest()
      })
      .skipNil()
      .observeValues { [weak self] in
        self?.projectImageView.af_setImageWithURL($0)
    }

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
  }
}
