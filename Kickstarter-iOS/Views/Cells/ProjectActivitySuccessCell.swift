import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivitySuccessCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivitySuccessCellViewModelType = ProjectActivitySuccessCellViewModel()

  @IBOutlet fileprivate weak var backgroundImageView: UIImageView!
  @IBOutlet fileprivate weak var dropShadowView: UIView!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backgroundImageURL
      .observeForUI()
      .on(event: { [weak backgroundImageView] _ in
        backgroundImageView?.af_cancelImageRequest()
        backgroundImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak backgroundImageView] url in
        backgroundImageView?.af_setImage(withURL: url)
    }

    self.viewModel.outputs.title.observeForUI()
      .observeValues { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_body(),
          bold: UIFont.ksr_body().bolded,
          italic: nil
        )

        titleLabel
          |> projectActivityStateChangeLabelStyle
          |> UILabel.lens.textColor .~ .white
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ProjectActivitySuccessCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.Opens_project()
    }

    self.cardView
      |> roundedStyle()
      |> UIView.lens.layoutMargins .~ .init(all: 24.0)

    self.dropShadowView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .white
      |> dropShadowStyle()
  }
}
