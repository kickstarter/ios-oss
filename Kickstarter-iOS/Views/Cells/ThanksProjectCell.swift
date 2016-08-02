import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ThanksProjectCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!

  func configureWith(value project: Project) {
    projectNameLabel
      |> UILabel.lens.text .~ project.name
      |> UILabel.lens.font .~ .ksr_callout()
      |> UILabel.lens.textColor .~ .whiteColor()

    self.projectImageView.af_cancelImageRequest()
    self.projectImageView.image = nil

    if let url = NSURL(string: project.photo.med) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
