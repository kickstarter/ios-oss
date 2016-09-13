import UIKit
import Library
import ReactiveCocoa
import KsApi

protocol FindFriendsStatsCellDelegate: class {
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount friendCount: Int)
}

internal final class FindFriendsStatsCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var friendCountLabel: StyledLabel!
  @IBOutlet private weak var backedProjectsCountLabel: StyledLabel!
  @IBOutlet private weak var followAllButton: BorderButton!

  internal weak var delegate: FindFriendsStatsCellDelegate?

  private let viewModel: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  override func bindViewModel() {
    super.bindViewModel()

    self.friendCountLabel.rac.text = self.viewModel.outputs.friendsCountText

    self.backedProjectsCountLabel.rac.text = self.viewModel.outputs.backedProjectsCountText

    self.followAllButton.rac.hidden = self.viewModel.outputs.hideFollowAllButton

    self.followAllButton.rac.title = self.viewModel.outputs.followAllText

    self.viewModel.outputs.notifyDelegateShowFollowAllFriendsAlert
      .observeForUI()
      .observeNext { [weak self] count in
        self?.delegate?.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: count)
    }
  }

  func configureWith(value value: (stats: FriendStatsEnvelope, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(stats: value.stats, source: value.source)
  }

  @IBAction func followAllButtonTapped(sender: AnyObject) {
    self.viewModel.inputs.followAllButtonTapped()
  }
}
