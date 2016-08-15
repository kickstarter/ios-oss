import KsApi
import Library
import Prelude
import UIKit

internal final class SearchProjectCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var columnsStackView: UIStackView!
  @IBOutlet private weak var imageShadowView: UIView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectLabel: UILabel!
  @IBOutlet private weak var projectNameContainerView: UIView!
  @IBOutlet private weak var separateView: UIView!

  func configureWith(value project: Project) {
    self.projectLabel.text = project.name

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = NSURL(string: project.photo.med) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> SearchProjectCell.lens.contentView.layoutMargins %~ {
        .init(top: Styles.grid(2), left: $0.left, bottom: Styles.grid(2), right: $0.right)
    }

    self.columnsStackView
      |> UIStackView.lens.alignment .~ .Top
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))

    self.imageShadowView
      |> dropShadowStyle()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.projectNameContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.grid(1), left: 0, bottom: 0, right: 0)
      |> UIView.lens.backgroundColor .~ .clearColor()

    self.separateView
      |> separatorStyle
  }
}
