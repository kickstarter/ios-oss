import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: BackerDashboardProjectCellViewModelType = BackerDashboardProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var mainContentContainerView: UIView!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var metadataStackView: UIStackView!
  @IBOutlet fileprivate weak var percentFundedLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var progressStaticView: UIView!
  @IBOutlet fileprivate weak var progressBarView: UIView!
  @IBOutlet fileprivate weak var savedIconImageView: UIImageView!

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func bindViewModel() {
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.metadataBackgroundColor
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.metadataIconImageView.rac.hidden = self.viewModel.outputs.metadataIconIsHidden
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.projectNameLabel.rac.attributedText = self.viewModel.outputs.projectTitleText
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.photoURL
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
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
    }

    _ = self.cardView
      |> cardStyle(cornerRadius: 0)

    _ = self.mainContentContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.gridHalf(3),
                                            left: Styles.grid(2),
                                            bottom: Styles.grid(1),
                                            right: Styles.grid(2))

    _ = self.metadataBackgroundView
      |> UIView.lens.layer.borderColor .~ UIColor.white.cgColor
      |> UIView.lens.layer.borderWidth .~ 1.0

    _ = self.metadataStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(30), leftRight: Styles.grid(20))

    _ = self.metadataLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .white

    _ = self.progressStaticView
      |> UIView.lens.backgroundColor .~ .ksr_dark_grey_900
      |> UIView.lens.alpha .~ 0.15

    _ = self.savedIconImageView
      |> UIImageView.lens.tintColor .~ .init(white: 1.0, alpha: 0.99)
  }
}
