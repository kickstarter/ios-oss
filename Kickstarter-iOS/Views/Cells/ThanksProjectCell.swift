import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ThanksProjectCell: UICollectionViewCell, ValueCell {

  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!

  fileprivate let viewModel: ThanksViewModelType = ThanksViewModel()

  func configureWith(value project: Project) {
    self
      |> UICollectionViewCell.lens.isAccessibilityElement .~ true
      |> UICollectionViewCell.lens.accessibilityLabel %~ { _ in project.name }
      |> UICollectionViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_project() }
      |> UICollectionViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    self.projectNameLabel
      |> UILabel.lens.text .~ project.name
      |> UILabel.lens.font .~ .ksr_callout()
      |> UILabel.lens.textColor .~ .white

    self.projectImageView.af_cancelImageRequest()
    self.projectImageView.image = nil

    if let url = URL(string: project.photo.med) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
