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

  internal override func bindStyles() { super.bindStyles() }
}
