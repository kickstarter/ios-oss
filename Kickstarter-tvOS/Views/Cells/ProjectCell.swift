import UIKit
import ReactiveCocoa
import KsApi
import AlamofireImage
import Prelude
import Library

class ProjectCell: UICollectionViewCell, ValueCell {
  let viewModel = SimpleViewModel<Project>()

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var unfocusedProjectNameLabel: UILabel!
  @IBOutlet private weak var fundedLabel: UILabel!
  @IBOutlet private weak var categoryLabel: UILabel!
  @IBOutlet private weak var focusedInfoView: UIView!

  func configureWith(value value: Project) {
    self.viewModel.model(value)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    let project = self.viewModel.model

    project
      .map { NSURL(string: $0.photo.full) }
      .ignoreNil()
      .skipRepeats()
      .on(next: { [weak self] _ in self?.imageView.image = nil })
      .observeForUI()
      .observeNext { [weak self] url in
        self?.imageView.af_setImageWithURL(url)
    }

    project
      .map { ($0.name, $0.category.name, $0.stats.percentFunded) }
      .skipRepeats(==)
      .observeForUI()
      .observeNext { [weak self] (name, category, percentFunded) in
        self?.projectNameLabel.text = name
        self?.unfocusedProjectNameLabel.text = name
        self?.categoryLabel.text = category
        self?.fundedLabel.text = "\(percentFunded)% funded"
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                        withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    self.focusedInfoView.hidden = !self.focused
  }
}
