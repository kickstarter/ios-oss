import UIKit
import Library
import ReactiveCocoa
import KsApi

internal final class ThanksProjectCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: StyledLabel!

  func configureWith(value project: Project) {
    projectNameLabel.text = project.name

    self.projectImageView.af_cancelImageRequest()
    self.projectImageView.image = nil

    if let url = NSURL(string: project.photo.med) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
