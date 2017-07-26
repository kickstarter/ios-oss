import KsApi
import Library
import Prelude
import UIKit

internal final class SearchProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SearchProjectCellViewModelType = SearchProjectCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectLabel: UILabel!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var percentFundedLabel: UILabel!
  @IBOutlet fileprivate weak var progressStaticView: UIView!
  @IBOutlet fileprivate weak var progressBarView: UIView!


  func configureWith(value project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> SearchProjectCell.lens.backgroundColor .~ .clear
      |> SearchProjectCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    _ = self.cardView
      |> dropShadowStyleMedium()

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

    _ = self.progressStaticView
      |> dropShadowStyleLarge()
      |> UIView.lens.backgroundColor .~ .black
      |> UIView.lens.alpha .~ 0.15
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.metadataLabel.rac.text = self.viewModel.outputs.metadataText
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.projectImageUrlMed
    self.projectLabel.rac.attributedText = self.viewModel.outputs.projectNameLabelText
    self.percentFundedLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.progressBarView.rac.backgroundColor = self.viewModel.outputs.progressBarColor
    self.metadataBackgroundView.rac.backgroundColor = self.viewModel.outputs.progressBarColor


    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak element = progressBarView] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        element?.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
    }
  }
}
