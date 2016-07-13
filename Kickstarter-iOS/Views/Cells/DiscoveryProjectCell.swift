import AlamofireImage
import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import UIKit

internal final class DiscoveryProjectCell: UITableViewCell, ValueCell {
  let viewModel: DiscoveryProjectViewModelType = DiscoveryProjectViewModel()

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var fundingLabel: UILabel!
  @IBOutlet weak var backersLabel: UILabel!

  override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
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
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self |> baseTableViewCellStyle()
      |> UITableViewCell.lens.accessibilityHint .~ "Open project"
  }

  func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }
}
