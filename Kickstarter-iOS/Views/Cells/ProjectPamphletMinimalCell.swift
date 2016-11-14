import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletMinimalCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var projectNameStackView: UIStackView!

  internal func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name

    self.projectImageView.image = nil
    NSURL(string: project.photo.full).doIfSome(self.projectImageView.ksr_setImageWithURL)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.activityIndicator
      |> UIActivityIndicatorView.lens.tintColor .~ .ksr_navy_700

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFit
      |> UIImageView.lens.backgroundColor .~ .blackColor()

    self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3(size: 28)
          : .ksr_title3(size: 20)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 0

    self.projectNameStackView
      |> UIStackView.lens.spacing .~ Styles.grid(6)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(top: Styles.grid(4), left: Styles.grid(4), bottom: Styles.grid(3), right: Styles.grid(4))
      }
  }
}
