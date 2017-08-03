import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityNegativeStateChangeCell: UITableViewCell, ValueCell {

  fileprivate let viewModel: ProjectActivityNegativeStateChangeCellViewModelType =
    ProjectActivityNegativeStateChangeCellViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.title.observeForUI()
      .observeValues { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_body(),
          bold: UIFont.ksr_body().bolded,
          italic: nil
        )

        _ = titleLabel
          |> projectActivityStateChangeLabelStyle
          |> UILabel.lens.textColor .~ .ksr_text_navy_500
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectActivityNegativeStateChangeCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_project() }

    _ = self.cardView
      |> cardStyle()
      |> dropShadowStyleMedium()
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_navy_500.cgColor
  }
}
