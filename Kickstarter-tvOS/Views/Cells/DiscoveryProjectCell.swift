import UIKit
import KsApi
import AlamofireImage
import ReactiveCocoa
import Library

final class DiscoveryProjectCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var creatorLabel: UILabel!

  let viewModel = SimpleViewModel<Project>()

  func configureWith(value value: Project) {
    self.viewModel.model(value)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    creatorLabel.hidden = true

    let project = self.viewModel.model

    projectNameLabel.rac.text = project.map { $0.name }
    creatorLabel.rac.text = project.map { $0.creator.name }

    project.map { NSURL(string: $0.photo.full) }
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.3))
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                        withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    let focused = self.focused

    coordinator.addCoordinatedAnimations({ [weak self] in
      self?.creatorLabel?.hidden = !focused
    }, completion: nil)
  }
}
