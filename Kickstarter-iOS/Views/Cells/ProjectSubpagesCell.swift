import UIKit
import Library
import ReactiveCocoa
import ReactiveExtensions
import KsApi

internal final class ProjectSubpagesCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectSubpagesViewModel = ProjectSubpagesViewModel()

  @IBOutlet internal weak var creatorImageView: UIImageView!
  @IBOutlet internal weak var creatorLabel: UILabel!
  @IBOutlet internal weak var disclaimerLabel: UILabel!

  override internal func bindViewModel() {

    self.viewModel.outputs.creatorImageURL
      .observeForUI()
      .on(next: { [weak imageView = creatorImageView]_ in
        imageView?.af_cancelImageRequest()
        imageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak imageView = creatorImageView] in imageView?.af_setImageWithURL($0) }

    self.creatorLabel.rac.text = self.viewModel.outputs.creatorName
    self.disclaimerLabel.rac.text = self.viewModel.outputs.disclaimer
    self.disclaimerLabel.rac.hidden = self.viewModel.outputs.disclaimerHidden
  }

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }
}
