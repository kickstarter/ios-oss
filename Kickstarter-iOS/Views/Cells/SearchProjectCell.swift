import UIKit
import Library
import KsApi

internal final class SearchProjectCell: UITableViewCell, ValueCell {
  @IBOutlet internal weak var projectLabel: UILabel!
  @IBOutlet internal weak var creatorLabel: UILabel!
  @IBOutlet internal weak var projectImageView: UIImageView!

  func configureWith(value project: Project) {
    self.projectLabel.text = project.name
    self.creatorLabel.text = project.creator.name

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = NSURL(string: project.photo.full) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
