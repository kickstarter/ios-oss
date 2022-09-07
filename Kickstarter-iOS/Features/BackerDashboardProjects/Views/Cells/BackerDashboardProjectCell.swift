import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: BackerDashboardProjectCellViewModelType = BackerDashboardProjectCellViewModel()

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var mainContentContainerView: UIView!
  @IBOutlet fileprivate var metadataBackgroundView: UIView!
  @IBOutlet fileprivate var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate var metadataLabel: UILabel!
  @IBOutlet fileprivate var metadataStackView: UIStackView!
  @IBOutlet fileprivate var percentFundedLabel: UILabel!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var progressStaticView: UIView!
  @IBOutlet fileprivate var progressBarView: UIView!
  @IBOutlet fileprivate var savedIconImageView: UIImageView!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func bindViewModel() {
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.metadataBackgroundColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.metadataIconImageView.rac.hidden = self.viewModel.outputs.metadataIconIsHidden
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.projectNameLabel.rac.attributedText = self.viewModel.outputs.projectTitleText
    self.projectImageView.rac.ksr_imageUrl = self.viewModel.outputs.photoURL
    self.progressBarView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.savedIconImageView.rac.hidden = self.viewModel.outputs.savedIconIsHidden

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
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraits.button
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      }

    _ = self.cardView
      |> cardStyle()

    _ = self.mainContentContainerView
      |> UIView.lens.layoutMargins .~ .init(
        top: Styles.gridHalf(3),
        left: Styles.grid(2),
        bottom: Styles.grid(1),
        right: Styles.grid(2)
      )

    _ = self.metadataBackgroundView
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_white.cgColor
      |> UIView.lens.layer.borderWidth .~ 1.0

    _ = self.metadataStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(30), leftRight: Styles.grid(20))

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_white

    _ = self.percentFundedLabel
      |> UILabel.lens.backgroundColor .~ .ksr_white

    _ = self.projectNameLabel
      |> UILabel.lens.backgroundColor .~ .ksr_white

    _ = self.progressStaticView
      |> UIView.lens.backgroundColor .~ .ksr_support_700
      |> UIView.lens.alpha .~ 0.15

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.savedIconImageView
      |> UIImageView.lens.tintColor .~ .init(white: 1.0, alpha: 0.99)
  }
}
