import class UIKit.UIImage
import class UIKit.UIColor
import class UIKit.UITableViewCell
import class UIKit.UIImageView
import class UIKit.UILabel
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~
import AlamofireImage
import class CoreImage.CIImage
import var CoreImage.kCIInputImageKey
import var CoreImage.kCIInputColorKey
import var CoreImage.kCIInputIntensityKey
import class CoreImage.CIFilter
import class CoreImage.CIColor

internal final class ActivityStateChangeCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ActivityStateChangeViewModel?>(nil)

  @IBOutlet internal weak var projectImageView: UIImageView!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var fundedSubtitleLabel: UILabel!
  @IBOutlet internal weak var pledgedTitleLabel: UILabel!
  @IBOutlet internal weak var pledgedSubtitleLabel: UILabel!

  override func bindViewModel() {
    super.bindViewModel()

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

    self.projectNameLabel.rac_text <~ self.viewModel.map { $0.outputs.projectName }
    self.fundedSubtitleLabel.rac_text <~ self.viewModel.map { $0.outputs.fundingDate }
    self.pledgedTitleLabel.rac_text <~ self.viewModel.map { $0.outputs.pledgedTitle }
    self.pledgedSubtitleLabel.rac_text <~ self.viewModel.map { $0.outputs.pledgedSubtitle }
  }
}
