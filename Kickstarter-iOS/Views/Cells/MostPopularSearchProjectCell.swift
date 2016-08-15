import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class MostPopularSearchProjectCell: UITableViewCell, ValueCell {
  private let viewModel: MostPopularSearchProjectCellViewModelType = MostPopularSearchProjectCellViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var fundingLabel: UILabel!
  @IBOutlet private weak var fundingProgressBarView: UIView!
  @IBOutlet private weak var fundingProgressContainerView: UIView!
  @IBOutlet private weak var fundingStackView: UIStackView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectInfoOverlayView: UIView!
  @IBOutlet private weak var projectInfoStackView: UIStackView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var separateView: UIView!

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> MostPopularSearchProjectCell.lens.contentView.layoutMargins %~ {
        .init(top: 0, left: $0.left, bottom: $0.bottom + Styles.grid(3), right: $0.right)
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
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectInfoOverlayView
      |> UIView.lens.backgroundColor .~ .init(white: 1.0, alpha: 0.95)
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.projectInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectNameLabel
      |> UILabel.lens.font .~ UIFont.ksr_title1(size: 18)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.lineBreakMode .~ .ByTruncatingTail

    self.separateView
      |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.fundingLabel.rac.text = self.viewModel.outputs.fundingLabelText

    self.viewModel.outputs.fundingProgress
      .observeForUI()
      .observeNext { [weak self] in
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(0.5 / $0), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransformMakeScale(CGFloat($0), 1.0)
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.image = nil
        self?.projectImageView.af_cancelImageRequest()
      })
      .ignoreNil()
      .observeNext { [weak self] in
        self?.projectImageView.af_setImageWithURL($0)
    }

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
  }
}
