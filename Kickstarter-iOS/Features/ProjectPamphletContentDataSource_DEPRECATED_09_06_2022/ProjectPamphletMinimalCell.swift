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
}
