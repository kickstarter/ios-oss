import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivitySuccessCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivitySuccessCellViewModelType = ProjectActivitySuccessCellViewModel()

  @IBOutlet fileprivate var backgroundImageView: UIImageView!
  @IBOutlet fileprivate var dropShadowView: UIView!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(
      activity: activityAndProject.0,
      project: activityAndProject.1
    )
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backgroundImageURL
      .observeForUI()
      .on(event: { [weak backgroundImageView] _ in
        backgroundImageView?.af.cancelImageRequest()
        backgroundImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak backgroundImageView] url in
        backgroundImageView?.af.setImage(withURL: url)
      }

    self.viewModel.outputs.title.observeForUI()
      .observeValues { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(
          font: .ksr_body(),
          bold: UIFont.ksr_body().bolded,
          italic: nil
        )

        _ = titleLabel
          |> projectActivityStateChangeLabelStyle
          |> UILabel.lens.textColor .~ .ksr_white
      }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectActivitySuccessCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.Opens_project()
      }

    _ = self.cardView
      |> roundedStyle()
      |> UIView.lens.layoutMargins .~ .init(all: 24.0)

    _ = self.dropShadowView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_white
      |> dropShadowStyleMedium()
  }
}
