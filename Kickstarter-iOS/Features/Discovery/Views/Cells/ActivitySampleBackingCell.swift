import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySampleBackingCellDelegate: AnyObject {
  /// Call when should go to activity screen.
  func goToActivity()
}

internal final class ActivitySampleBackingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySampleBackingCellViewModelType = ActivitySampleBackingCellViewModel()
  internal weak var delegate: ActivitySampleBackingCellDelegate?

  @IBOutlet fileprivate var activityStackView: UIStackView!
  @IBOutlet fileprivate var activityTitleLabel: UILabel!
  @IBOutlet fileprivate var backerImageAndInfoStackView: UIStackView!
  @IBOutlet fileprivate var backerImageView: CircleAvatarImageView!
  @IBOutlet fileprivate var backingTitleLabel: UILabel!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var seeAllActivityButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllActivityButton.addTarget(
      self,
      action: #selector(self.seeAllActivityButtonTapped),
      for: .touchUpInside
    )
  }

  internal override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backerImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.backerImageView.af.cancelImageRequest()
        self?.backerImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.backerImageView.ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.backingTitleText
      .observeForUI()
      .observeValues { [weak element = backingTitleLabel] attrString in
        element?.attributedText = attrString
      }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.goToActivity()
      }
  }

  internal func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  @objc fileprivate func seeAllActivityButtonTapped() {
    self.viewModel.inputs.seeAllActivityTapped()
  }
}
