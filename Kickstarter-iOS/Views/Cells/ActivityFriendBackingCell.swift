import UIKit
import Library
import ReactiveCocoa
import KsApi

internal final class ActivityFriendBackingCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendBackingViewModel = ActivityFriendBackingViewModel()

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendTitleLabel: UILabel!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var creatorNameLabel: UILabel!
  @IBOutlet internal weak var projectImageView: UIImageView!

  override func bindViewModel() {
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.friendTitleLabel.rac.text = self.viewModel.outputs.friendTitle
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorName

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(next: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak friendImageView] url in
        friendImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak projectImageView] url in
        projectImageView?.af_setImageWithURL(url)
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }
}
