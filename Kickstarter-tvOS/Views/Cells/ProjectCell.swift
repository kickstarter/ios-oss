import UIKit
import ReactiveCocoa
import Models
import AlamofireImage
import Prelude
import protocol Library.ViewModeledCellType
import class Library.SimpleViewModel

class ProjectCell: UICollectionViewCell, ViewModeledCellType {
  let viewModel = MutableProperty<SimpleViewModel<Project>?>(nil)

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var unfocusedProjectNameLabel: UILabel!
  @IBOutlet weak var fundedLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var focusedInfoView: UIView!

  override func bindViewModel() {
    let project = viewModel.producer.map { $0?.model }.ignoreNil()

    project
      .map { $0.photo.full }
      .flatMap(NSURL.init)
      .skipRepeats()
      .on(next: { [weak self] _ in self?.imageView.image = nil })
      .observeForUI()
      .startWithNext { [weak self] url in
        self?.imageView.af_setImageWithURL(url)
    }

    project
      .map { ($0.name, $0.category.name, $0.percentFunded) }
      .skipRepeats(==)
      .observeForUI()
      .startWithNext { [weak self] (name, category, percentFunded) in
        self?.projectNameLabel.text = name
        self?.unfocusedProjectNameLabel.text = name
        self?.categoryLabel.text = category
        self?.fundedLabel.text = "\(percentFunded)% funded"
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    self.focusedInfoView.hidden = !self.focused
  }
}
