import UIKit
import Models
import AlamofireImage
import ReactiveCocoa
import protocol Library.ViewModeledCellType
import class Library.SimpleViewModel

final class DiscoveryProjectCell: UICollectionViewCell, ViewModeledCellType {

  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var creatorLabel: UILabel!

  let viewModelProperty = MutableProperty<SimpleViewModel<Project>?>(nil)

  override func awakeFromNib() {
    super.awakeFromNib()
    creatorLabel.hidden = true
  }

  override func bindViewModel() {
    super.bindViewModel()

    let project = self.viewModel.map { $0.model }

    projectNameLabel.rac_text <~ project.map { $0.name }
    creatorLabel.rac_text <~ project.map { $0.creator.name }

    project.map { NSURL(string: $0.photo.full) }
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .ignoreNil()
      .startWithNext { [weak self] url in
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
