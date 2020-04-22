import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityUpdateCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivityUpdateCellViewModelType = ProjectActivityUpdateCellViewModel()

  @IBOutlet fileprivate var activityTitleLabel: UILabel!
  @IBOutlet fileprivate var bodyLabel: UILabel!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var commentsCountImageView: UIImageView!
  @IBOutlet fileprivate var commentsCountLabel: UILabel!
  @IBOutlet fileprivate var commentsStackView: UIStackView!
  @IBOutlet fileprivate var containerStackView: UIStackView!
  @IBOutlet fileprivate var contentAndFooterStackView: UIStackView!
  @IBOutlet fileprivate var footerDividerView: UIView!
  @IBOutlet fileprivate var likeAndCommentsCountStackView: UIStackView!
  @IBOutlet fileprivate var likesCountImageView: UIImageView!
  @IBOutlet fileprivate var likesCountLabel: UILabel!
  @IBOutlet fileprivate var likesStackView: UIStackView!
  @IBOutlet fileprivate var updateTitleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(
      activity: activityAndProject.0,
      project: activityAndProject.1
    )
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activityTitle.observeForUI()
      .observeValues { [weak activityTitleLabel] title in
        guard let activityTitleLabel = activityTitleLabel else { return }

        activityTitleLabel.attributedText = title.simpleHtmlAttributedString(
          font: .ksr_title3(size: 14),
          bold: UIFont.ksr_title3(size: 14).bolded,
          italic: nil
        )

        _ = activityTitleLabel
          |> projectActivityTitleLabelStyle
      }

    self.bodyLabel.rac.text = self.viewModel.outputs.body
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.commentsCountLabel.rac.text = self.viewModel.outputs.commentsCount
    self.likesCountLabel.rac.text = self.viewModel.outputs.likesCount
    self.updateTitleLabel.rac.text = self.viewModel.outputs.updateTitle
  }

  internal override func bindStyles() {
    super.bindStyles()

    let statLabel =
      UILabel.lens.font .~ .ksr_caption1(size: 12)
        <> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectActivityUpdateCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_update() }

    _ = self.cardView
      |> dropShadowStyleMedium()

    _ = self.bodyLabel
      |> UILabel.lens.numberOfLines .~ 4
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_body()
          : UIFont.ksr_body(size: 14)
      }

    _ = self.commentsCountImageView
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_500

    _ = self.commentsCountLabel
      |> statLabel

    _ = self.commentsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.containerStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.contentAndFooterStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.footerDividerView
      |> projectActivityDividerViewStyle

    _ = self.likeAndCommentsCountStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.likesCountImageView
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_500

    _ = self.likesCountLabel
      |> statLabel

    _ = self.likesStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.updateTitleLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.textColor .~ .ksr_soft_black
  }
}
