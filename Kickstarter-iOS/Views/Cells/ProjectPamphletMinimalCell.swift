import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletMinimalCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var projectNameStackView: UIStackView!

  internal func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name

    self.projectImageView.image = nil
    URL(string: project.photo.full)
      .doIfSome { self.projectImageView.ksr_setImageWithURL($0) }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.activityIndicator
      |> UIActivityIndicatorView.lens.tintColor .~ .ksr_support_400

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.backgroundColor .~ .ksr_support_700

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3(size: 28)
          : .ksr_title3(size: 20)
      }
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.projectNameStackView
      |> UIStackView.lens.spacing .~ Styles.grid(15)
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(6), left: Styles.grid(16), bottom: Styles.grid(18), right: Styles.grid(16))
          : .init(top: Styles.grid(4), left: Styles.grid(4), bottom: Styles.grid(16), right: Styles.grid(4))
      }
  }
}
