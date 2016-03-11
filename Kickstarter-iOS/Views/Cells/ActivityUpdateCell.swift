import class UIKit.UITableViewCell
import class UIKit.UILabel
import class UIKit.UIImageView
import protocol Library.ViewModeledCellType
import class ReactiveCocoa.MutableProperty
import struct ReactiveCocoa.SignalProducer
import ReactiveExtensions
import ReactiveCocoa
import struct Models.Activity

internal final class ActivityUpdateCell: UITableViewCell, ViewModeledCellType {
  internal let viewModelProperty = MutableProperty<ActivityUpdateViewModel?>(nil)

  @IBOutlet weak var projectImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var updateSequenceLabel: UILabel!
  @IBOutlet weak var timestampLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!

  override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac_text <~ self.viewModel.map { $0.outputs.projectName }
    self.updateSequenceLabel.rac_text <~ self.viewModel.map { $0.outputs.sequenceTitle }
    self.timestampLabel.rac_text <~ self.viewModel.map { $0.outputs.timestamp }
    self.titleLabel.rac_text <~ self.viewModel.map { $0.outputs.title }
    self.bodyLabel.rac_text <~ self.viewModel.map { $0.outputs.body }

    self.viewModel.map { $0.projectImageURL }
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
