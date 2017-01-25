import KsApi
import Library
import Prelude
import UIKit

internal final class SearchProjectCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SearchProjectCellViewModelType = SearchProjectCellViewModel()

  @IBOutlet fileprivate weak var columnsStackView: UIStackView!
  @IBOutlet fileprivate weak var imageShadowView: UIView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectImageWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var projectLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameContainerView: UIView!
  @IBOutlet fileprivate weak var separateView: UIView!
  @IBOutlet fileprivate weak var fundingSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var fundingTitleLabel: UILabel!
  @IBOutlet fileprivate weak var deadlineSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var deadlineTitleLabel: UILabel!
  @IBOutlet fileprivate weak var statsStackView: UIStackView!

  func configureWith(value project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

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

    _ = [self.fundingSubtitleLabel, self.deadlineSubtitleLabel]
      ||> UILabel.lens.font .~ .ksr_body(size: 13)
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = [self.fundingTitleLabel, self.deadlineTitleLabel]
      ||> UILabel.lens.font .~ .ksr_headline(size: 13)

    _ = self.fundingTitleLabel |> UILabel.lens.textColor .~ .ksr_text_green_700

    _ = self.deadlineTitleLabel |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.columnsStackView
      |> UIStackView.lens.alignment .~ .top
      |> UIStackView.lens.spacing %~~ { _, stackView in
        stackView.traitCollection.isRegularRegular
          ? Styles.grid(4)
          : Styles.grid(2)
      }
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))

    _ = self.imageShadowView |> dropShadowStyle()

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectImageWidthConstraint.constant = self.traitCollection.isRegularRegular ? 140 : 80

    _ = self.projectLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3()
          : .ksr_headline(size: 14)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.projectNameContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.grid(1), left: 0, bottom: 0, right: 0)
      |> UIView.lens.backgroundColor .~ .clear

    _ = self.separateView |> separatorStyle

    _ = self.statsStackView |> UIStackView.lens.spacing .~ Styles.grid(1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.fundingSubtitleLabel.rac.text = self.viewModel.outputs.fundingSubtitleLabelText
    self.fundingTitleLabel.rac.text = self.viewModel.outputs.fundingTitleLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.projectImageUrl
    self.projectLabel.rac.text = self.viewModel.outputs.projectNameLabelText
  }
}
