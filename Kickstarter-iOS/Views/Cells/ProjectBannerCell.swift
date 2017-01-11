import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectBannerCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var creatorNameLabel: UILabel!

  func configureWith(value project: Project) {
    self.projectNameLabel.text = project.name
    self.creatorNameLabel.text = project.creator.name
    self.projectImageView.af_cancelImageRequest()
    self.projectImageView.image = nil
    if let url = URL(string: project.photo.full) {
      self.projectImageView.af_setImage(withURL: url)
    }
  }

  internal override func bindStyles() {
    _ = self.projectNameLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_title1(size: 16)

    _ = self.creatorNameLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
  }
}
