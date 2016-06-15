import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude
import KsApi

internal final class FindFriendsViewController: UITableViewController {

  private let viewModel: FindFriendsViewModelType = FindFriendsViewModel()
  private let dataSource = FindFriendsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 100.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.friends
      .observeForUI()
      .observeNext { [weak self] (friends, source) in
        self?.dataSource.friends(friends, source: source)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.stats
      .observeForUI()
      .observeNext { [weak self] (stats, source) in
        self?.dataSource.stats(stats: stats, source: source)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFacebookConnect
      .observeForUI()
      .observeNext { [weak self] (source, visible) in
        self?.dataSource.facebookConnect(source: source, visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFollowAllFriendsAlert
      .observeForUI()
      .observeNext { [weak self] count in
        self?.showFollowAllConfirmationAlert(count: count)
    }

    self.viewModel.outputs.title
      .observeForUI()
      .observeNext { [weak self] text in self?.title = text
    }

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeNext { [weak self] error in
      self?.presentViewController(
        UIAlertController.alertController(forError: error),
        animated: true,
        completion: nil
      )
    }
  }

  internal func configureWith(source source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                          forRowAtIndexPath indexPath: NSIndexPath) {

    if let statsCell = cell as? FindFriendsStatsCell where statsCell.delegate == nil {
      statsCell.delegate = self
    } else if let fbConnectCell = cell as? FindFriendsFacebookConnectCell
      where fbConnectCell.delegate == nil {
      fbConnectCell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  private func showFollowAllConfirmationAlert(count count: Int) {
    self.presentViewController(
      UIAlertController.confirmFollowAllFriends(
        friendsCount: count,
        yesHandler: { _ in
          self.viewModel.inputs.confirmFollowAllFriends()
        },
        noHandler: { _ in
          self.viewModel.inputs.declineFollowAllFriends()
        }
      ),
      animated: true,
      completion: nil
    )
  }
}

extension FindFriendsViewController: FindFriendsStatsCellDelegate {
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount friendCount: Int) {
    self.viewModel.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: friendCount)
  }
}

extension FindFriendsViewController: FindFriendsFacebookConnectCellDelegate {
  func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    self.viewModel.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()
  }

  func findFriendsFacebookConnectCellDidDismissHeader() {}

  func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError) {
    self.viewModel.inputs.findFriendsFacebookConnectCellShowErrorAlert(alert)
  }
}
