import class UIKit.UITableViewCell
import class UIKit.UILabel
import protocol Library.ViewModeledCellType
import ReactiveCocoa
import enum Result.NoError
import ReactiveExtensions
import AlamofireImage

internal final class DiscoveryProjectCell: UITableViewCell, ViewModeledCellType {
  let viewModelProperty = MutableProperty<DiscoveryProjectViewModel?>(nil)

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var fundingLabel: UILabel!
  @IBOutlet weak var backersLabel: UILabel!

  override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac_text <~ self.viewModel.map { $0.outputs.projectName }
    self.categoryLabel.rac_text <~ self.viewModel.map { $0.outputs.category }
    self.blurbLabel.rac_text <~ self.viewModel.map { $0.outputs.blurb }
    self.fundingLabel.rac_text <~ self.viewModel.map { $0.outputs.funding }
    self.backersLabel.rac_text <~ self.viewModel.map { $0.outputs.backers }

    self.viewModel.map { $0.outputs.projectImageURL }
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .ignoreNil()
      .startWithNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }
}
