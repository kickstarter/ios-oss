import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectBannerCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var creatorNameLabel: UILabel!

  func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name
    self.creatorNameLabel.text = project.creator.name
    self.projectImageView.af.cancelImageRequest()
    self.projectImageView.image = nil
    if let url = URL(string: project.photo.full) {
      self.projectImageView.af.setImage(withURL: url)
    }
  }

  internal override func bindStyles() {
    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.projectNameLabel
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.font .~ .ksr_title1(size: 16)

    _ = self.creatorNameLabel
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
  }
}
