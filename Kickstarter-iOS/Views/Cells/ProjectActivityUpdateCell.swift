import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityUpdateCell: UITableViewCell, ValueCell {

  private let viewModel: ProjectActivityUpdateCellViewModelType = ProjectActivityUpdateCellViewModel()

  @IBOutlet private weak var activityTitleLabel: UILabel!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var commentsCountImageView: UIImageView!
  @IBOutlet private weak var commentsCountLabel: UILabel!
  @IBOutlet private weak var footerDividerView: UIView!
  @IBOutlet private weak var likesCountImageView: UIImageView!
  @IBOutlet private weak var likesCountLabel: UILabel!
  @IBOutlet private weak var updateTitleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activityTitle.observeForUI()
      .observeNext { [weak activityTitleLabel] title in
        guard let activityTitleLabel = activityTitleLabel else { return }

        activityTitleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_title3(size: 14),
          bold: UIFont.ksr_title3(size: 14).bolded,
          italic: nil
        )

        activityTitleLabel |> projectActivityTitleLabelStyle
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

    self |> baseTableViewCellStyle()
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        localizedString(key: "key.todo", defaultValue: "Opens update.")
    }

    self.cardView |> projectActivityCardStyle

    self.bodyLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.numberOfLines .~ 5
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.commentsCountImageView |> UIImageView.lens.tintColor .~ .ksr_navy_600

    self.commentsCountLabel |> statLabel

    self.footerDividerView |> UIView.lens.backgroundColor .~ .ksr_navy_300

    self.likesCountImageView |> UIImageView.lens.tintColor .~ .ksr_navy_600

    self.likesCountLabel |> statLabel

    self.updateTitleLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
  }
}
