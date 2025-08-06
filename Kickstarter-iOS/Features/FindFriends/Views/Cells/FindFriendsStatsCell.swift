import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsStatsCellDelegate: AnyObject {
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: Int)
}

internal final class FindFriendsStatsCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var backedProjectsLabel: UILabel!
  @IBOutlet fileprivate var bulletSeparatorView: UIView!
  @IBOutlet fileprivate var friendsLabel: UILabel!
  @IBOutlet fileprivate var friendsCountLabel: UILabel!
  @IBOutlet fileprivate var backedProjectsCountLabel: UILabel!
  @IBOutlet fileprivate var followAllButton: UIButton!

  internal weak var delegate: FindFriendsStatsCellDelegate?

  fileprivate let viewModel: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  func configureWith(value: (stats: FriendStatsEnvelope, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(stats: value.stats, source: value.source)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.friendsCountLabel.rac.text = self.viewModel.outputs.friendsCountText

    self.backedProjectsCountLabel.rac.text = self.viewModel.outputs.backedProjectsCountText

    self.followAllButton.rac.hidden = self.viewModel.outputs.hideFollowAllButton

    self.followAllButton.rac.title = self.viewModel.outputs.followAllText

    self.viewModel.outputs.notifyDelegateShowFollowAllFriendsAlert
      .observeForUI()
      .observeValues { [weak self] count in
        self?.delegate?.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: count)
      }
  }

  override func bindStyles() { super.bindStyles() }

  @objc func followAllButtonTapped() {
    self.viewModel.inputs.followAllButtonTapped()
  }
}
