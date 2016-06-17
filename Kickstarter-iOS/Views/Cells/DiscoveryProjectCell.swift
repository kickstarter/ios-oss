import UIKit
import Library
import ReactiveCocoa
import ReactiveExtensions
import AlamofireImage
import KsApi

internal final class DiscoveryProjectCell: UITableViewCell, ValueCell {
  let viewModel: DiscoveryProjectViewModelType = DiscoveryProjectViewModel()

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var fundingLabel: UILabel!
  @IBOutlet weak var backersLabel: UILabel!

  override func bindViewModel() {
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.categoryLabel.rac.text = self.viewModel.outputs.category
    self.blurbLabel.rac.text = self.viewModel.outputs.blurb
    self.fundingLabel.rac.text = self.viewModel.outputs.funding
    self.backersLabel.rac.text = self.viewModel.outputs.backers

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        print("[self.viewModel.outputs.projectImageURL] \(url)")
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }
}
