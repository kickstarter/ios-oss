import Foundation
import UIKit
import ReactiveExtensions
import ReactiveSwift
import Library
import Prelude
import KsApi

internal final class FindFriendsViewController: UITableViewController {

  fileprivate let viewModel: FindFriendsViewModelType = FindFriendsViewModel()
  fileprivate let dataSource = FindFriendsDataSource()

  internal static func configuredWith(source: FriendsSource) -> FindFriendsViewController {
    let vc = Storyboard.Friends.instantiate(FindFriendsViewController)
    vc.viewModel.inputs.configureWith(source: source)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 100.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.friends
      .observeForUI()
      .observeValues { [weak self] (friends, source) in
        self?.dataSource.friends(friends, source: source)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.stats
      .observeForUI()
      .observeValues { [weak self] (stats, source) in
        self?.dataSource.stats(stats: stats, source: source)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFacebookConnect
      .observeForUI()
      .observeValues { [weak self] (source, visible) in
        self?.dataSource.facebookConnect(source: source, visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFollowAllFriendsAlert
      .observeForUI()
      .observeValues { [weak self] count in
        self?.showFollowAllConfirmationAlert(count: count)
    }

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] error in
      self?.present(
        UIAlertController.alertController(forError: error),
        animated: true,
        completion: nil
      )
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Follow_friends() }

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {

    if let statsCell = cell as? FindFriendsStatsCell, statsCell.delegate == nil {
      statsCell.delegate = self
    } else if let fbConnectCell = cell as? FindFriendsFacebookConnectCell, fbConnectCell.delegate == nil {
      fbConnectCell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  fileprivate func showFollowAllConfirmationAlert(count: Int) {
    self.present(
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
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: Int) {
    self.viewModel.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: friendCount)
  }
}

extension FindFriendsViewController: FindFriendsFacebookConnectCellDelegate {
  func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    self.viewModel.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()
  }

  func findFriendsFacebookConnectCellDidDismissHeader() {}

  func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError) {
    self.viewModel.inputs.findFriendsFacebookConnectCellShowErrorAlert(alert)
  }
}
