import UIKit
import Library
import ReactiveCocoa
import Models

internal final class ActivityFriendFollowCell: UITableViewCell, ValueCell {
  private var viewModel: ActivityFriendFollowViewModel!

  @IBOutlet internal weak var friendImageView: UIImageView!
  @IBOutlet internal weak var friendLabel: UILabel!
  @IBOutlet internal weak var followButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.viewModel = ActivityFriendFollowViewModel()

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

    self.viewModel.outputs.title
      .observeForUI()
      .observeNext { [weak friendLabel] title in
        friendLabel?.text = title
    }

    self.viewModel.outputs.hideFollowButton
      .observeForUI()
      .observeNext { [weak followButton] hide in
        followButton?.hidden = hide
    }
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }

  @IBAction
  internal func followButtonPressed() {
    self.viewModel.inputs.followButtonPressed()
  }
}
