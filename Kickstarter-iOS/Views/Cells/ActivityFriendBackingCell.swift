import UIKit
import Library
import ReactiveCocoa
import Models

internal final class ActivityFriendBackingCell: UITableViewCell, ValueCell {
  var viewModel: ActivityFriendBackingViewModel!

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendTitleLabel: UILabel!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var creatorNameLabel: UILabel!
  @IBOutlet internal weak var projectImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.viewModel = ActivityFriendBackingViewModel()

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

    self.viewModel.outputs.friendTitle
      .observeForUI()
      .observeNext { [weak friendTitleLabel] title in
        friendTitleLabel?.text = title
    }

    self.viewModel.outputs.projectName
      .observeForUI()
      .observeNext { [weak projectNameLabel] name in
        projectNameLabel?.text = name
    }

    self.viewModel.outputs.creatorName
      .observeForUI()
      .observeNext { [weak creatorNameLabel] name in
        creatorNameLabel?.text = name
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
