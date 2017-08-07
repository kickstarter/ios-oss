import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileProjectCell: UICollectionViewCell, ValueCell {
  fileprivate let viewModel: ProfileProjectCellViewModelType = ProfileProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var progressView: UIView!
  @IBOutlet fileprivate weak var progressBarView: UIView!
  @IBOutlet fileprivate weak var stateBannerView: UIView!
  @IBOutlet fileprivate weak var stateLabel: UILabel!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.project(value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UICollectionViewCell.lens.backgroundColor .~ .clear
      |> UICollectionViewCell.lens.isAccessibilityElement .~ true
      |> UICollectionViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_project() }
      |> UICollectionViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    _ = self.cardView
      |> dropShadowStyle()

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.projectNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_callout(size: 15)

    _ = self.stateLabel
      |> UILabel.lens.textColor .~ .white
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
      .on(event: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.af_setImage(withURL: url)
    }

    self.progressView.rac.hidden = self.viewModel.outputs.progressHidden
    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
    }

    self.stateBannerView.rac.hidden = self.viewModel.outputs.stateHidden
    self.stateBannerView.rac.backgroundColor = self.viewModel.outputs.stateBackgroundColor
    self.stateLabel.rac.text = self.viewModel.outputs.stateLabelText
  }
}
