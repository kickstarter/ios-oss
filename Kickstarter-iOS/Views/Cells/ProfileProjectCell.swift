import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProfileProjectCellViewModelType = ProfileProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var mainContentContainerView: UIView!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var percentFundedLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var progressStaticView: UIView!
  @IBOutlet fileprivate weak var progressBarView: UIView!
  @IBOutlet fileprivate weak var savedIconImageView: UIImageView!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.project(value)
  }

  internal override func bindViewModel() {
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.metadataIconImageView.rac.hidden = self.viewModel.outputs.metadataIconIsHidden
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.projectNameLabel.rac.attributedText = self.viewModel.outputs.projectTitleText
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.photoURL
    self.progressBarView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.savedIconImageView.rac.hidden = self.viewModel.outputs.savedIconIsHidden

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel

    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.isAccessibilityElement .~ true
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_project() }
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    _ = self.cardView
      |> dropShadowStyle()

    _ = self.mainContentContainerView
      |> UIView.lens.backgroundColor .~ .white
      |> UIView.lens.layoutMargins .~ .init(top: Styles.gridHalf(3),
                                            left: Styles.grid(2),
                                            bottom: Styles.grid(2),
                                            right: Styles.grid(2))

    _ = self.metadataBackgroundView
      |> dropShadowStyle()
      |> UIView.lens.layer.shadowColor .~ UIColor.black.cgColor
      |> UIView.lens.layer.shadowOpacity .~ 0.3
      |> UIView.lens.layer.cornerRadius .~ 2.0
      |> UIView.lens.backgroundColor .~ .ksr_green_500

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .white

    _ = self.progressStaticView
      |> UIView.lens.backgroundColor .~ .black
      |> UIView.lens.alpha .~ 0.15

    _ = self.savedIconImageView
      |> UIImageView.lens.tintColor .~ .init(white: 1.0, alpha: 0.99)
  }
}
