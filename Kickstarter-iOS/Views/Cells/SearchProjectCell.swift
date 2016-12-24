import KsApi
import Library
import Prelude
import UIKit

internal final class SearchProjectCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var columnsStackView: UIStackView!
  @IBOutlet fileprivate weak var imageShadowView: UIView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectImageWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var projectLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameContainerView: UIView!
  @IBOutlet fileprivate weak var separateView: UIView!

  func configureWith(value project: Project) {
    self.projectLabel.text = project.name

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = URL(string: project.photo.med) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> SearchProjectCell.lens.backgroundColor .~ .clear
      |> SearchProjectCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    self.columnsStackView
      |> UIStackView.lens.alignment .~ .Top
      |> UIStackView.lens.spacing %~~ { _, stackView in
        stackView.traitCollection.isRegularRegular
          ? Styles.grid(4)
          : Styles.grid(2)
      }
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))

    self.imageShadowView
      |> dropShadowStyle()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectImageWidthConstraint.constant = self.traitCollection.isRegularRegular ? 140 : 80

    self.projectLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3()
          : .ksr_headline(size: 14)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.projectNameContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.grid(1), left: 0, bottom: 0, right: 0)
      |> UIView.lens.backgroundColor .~ .clear

    self.separateView
      |> separatorStyle
  }
}
