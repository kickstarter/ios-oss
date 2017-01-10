import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletMinimalCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameStackView: UIStackView!

  internal func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name

    self.projectImageView.image = nil
    URL(string: project.photo.full).doIfSome(self.projectImageView.ksr_setImageWithURL)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.activityIndicator
      |> UIActivityIndicatorView.lens.tintColor .~ .ksr_navy_700

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.backgroundColor .~ .black

    _ = self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3(size: 28)
          : .ksr_title3(size: 20)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.projectNameStackView
      |> UIStackView.lens.spacing .~ Styles.grid(6)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(top: Styles.grid(4), left: Styles.grid(4), bottom: Styles.grid(3), right: Styles.grid(4))
      }
  }
}
