import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectBannerCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var creatorNameLabel: UILabel!

  func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name
    self.creatorNameLabel.text = project.creator.name
    self.projectImageView.af_cancelImageRequest()
    self.projectImageView.image = nil
    if let url = NSURL(string: project.photo.full) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }

  internal override func bindStyles() {
    self.projectNameLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_title1(size: 16)

    self.creatorNameLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
  }
}
