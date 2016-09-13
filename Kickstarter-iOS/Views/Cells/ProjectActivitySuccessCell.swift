import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivitySuccessCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectActivitySuccessCellViewModelType = ProjectActivitySuccessCellViewModel()

  @IBOutlet private weak var backgroundImageView: UIImageView!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var titleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backgroundImageURL
      .observeForUI()
      .on(next: { [weak backgroundImageView] _ in
        backgroundImageView?.af_cancelImageRequest()
        backgroundImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak backgroundImageView] url in
        backgroundImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.title.observeForUI()
      .observeNext { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_body(),
          bold: UIFont.ksr_body().bolded,
          italic: nil
        )

        titleLabel
          |> projectActivityStateChangeLabelStyle
          |> UILabel.lens.textColor .~ .whiteColor()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self |> baseTableViewCellStyle()
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.Opens_project()
    }

    self.cardView
      |> roundedStyle()
      |> UIView.lens.layoutMargins .~ .init(all: 24.0)
  }
}
