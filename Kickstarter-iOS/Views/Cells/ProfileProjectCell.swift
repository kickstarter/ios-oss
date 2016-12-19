import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileProjectCell: UICollectionViewCell, ValueCell {
  private let viewModel: ProfileProjectCellViewModelType = ProfileProjectCellViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var metadataBackgroundView: UIView!
  @IBOutlet private weak var metadataLabel: UILabel!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var progressView: UIView!
  @IBOutlet private weak var progressBarView: UIView!
  @IBOutlet private weak var stateBannerView: UIView!
  @IBOutlet private weak var stateLabel: UILabel!

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> UICollectionViewCell.lens.backgroundColor .~ .clearColor()
      |> UICollectionViewCell.lens.isAccessibilityElement .~ true
      |> UICollectionViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_project() }
      |> UICollectionViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    self.cardView
      |> dropShadowStyle()

    self.metadataLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    self.projectNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_callout(size: 15)

    self.stateLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.numberOfLines .~ 0
  }

  internal override func bindViewModel() {
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.metadataLabel.rac.hidden = self.viewModel.outputs.metadataIsHidden
    self.metadataBackgroundView.rac.hidden = self.viewModel.outputs.metadataIsHidden
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel

    self.viewModel.outputs.photoURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .skipNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }

    self.progressView.rac.hidden = self.viewModel.outputs.progressHidden
    self.viewModel.outputs.progress
      .observeForUI()
      .observeNext { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransformMakeScale(CGFloat(min(progress, 1.0)), 1.0)
    }

    self.stateBannerView.rac.hidden = self.viewModel.outputs.stateHidden
    self.stateBannerView.rac.backgroundColor = self.viewModel.outputs.stateBackgroundColor
    self.stateLabel.rac.text = self.viewModel.outputs.stateLabelText
  }
}
