import UIKit
import Library
import ReactiveCocoa
import ReactiveExtensions
import AlamofireImage
import Models

internal final class DiscoveryProjectCell: UITableViewCell, ValueCell {
  let viewModel: DiscoveryProjectViewModelType = DiscoveryProjectViewModel()

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var fundingLabel: UILabel!
  @IBOutlet weak var backersLabel: UILabel!

  override func bindViewModel() {
    self.viewModel.outputs.projectName
      .observeForUI()
      .observeNext { [weak projectNameLabel] projectName in
        projectNameLabel?.text = projectName
    }

    self.viewModel.outputs.category
      .observeForUI()
      .observeNext { [weak categoryLabel] category in
        categoryLabel?.text = category
    }

    self.viewModel.outputs.blurb
      .observeForUI()
      .observeNext { [weak blurbLabel] blurb in
        blurbLabel?.text = blurb
    }

    self.viewModel.outputs.funding
      .observeForUI()
      .observeNext { [weak fundingLabel] funding in
        fundingLabel?.text = funding
    }

    self.viewModel.outputs.backers
      .observeForUI()
      .observeNext { [weak backersLabel] backers in
        backersLabel?.text = backers
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }
}
