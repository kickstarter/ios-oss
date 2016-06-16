import Foundation
import Library
import UIKit
import ReactiveCocoa
import KsApi

internal final class ActivitiesViewController: UITableViewController {
  let viewModel: ActivitiesViewModelType = ActivitiesViewModel()
  let dataSource = ActivitiesDataSource()

  internal required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 300.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = dataSource
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }


  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .observeNext { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFacebookConnectSection
      .observeForUI()
      .observeNext { [weak self] source, shouldShow in
        self?.dataSource.facebookConnect(source: source, visible: shouldShow)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showFindFriendsSection
      .observeForUI()
      .observeNext { [weak self] source, shouldShow in
        self?.dataSource.findFriends(source: source, visible: shouldShow)
        self?.tableView.reloadData()
    }

    Signal.merge(
      self.viewModel.outputs.showLoggedOutEmptyState,
      self.viewModel.outputs.showLoggedInEmptyState
      )
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.isRefreshing
      .observeForUI()
      .observeNext { [weak control = self.refreshControl] in
        $0 ? control?.beginRefreshing() : control?.endRefreshing()
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.present(project: project, refTag: refTag)
    }

    self.viewModel.outputs.deleteFacebookConnectSection
      .observeForUI()
      .observeNext { [weak self] in
        self?.deleteFacebookSection()
    }

    self.viewModel.outputs.deleteFindFriendsSection
      .observeForUI()
      .observeNext { [weak self] in
        self?.deleteFindFriendsSection()
    }

    self.viewModel.outputs.goToFriends
      .observeForUI()
      .observeNext { [weak self] source in
        self?.goToFriends(source: source)
    }

    self.viewModel.outputs.showFacebookConnectErrorAlert
      .observeForUI()
      .observeNext { [weak self] error in
        self?.presentViewController(
          UIAlertController.alertController(forError: error),
          animated: true,
          completion: nil
        )
    }
  }
  // swiftlint:enable function_body_length

  internal override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                                          forRowAtIndexPath indexPath: NSIndexPath) {

    if let activityUpdateCell = cell as? ActivityUpdateCell where activityUpdateCell.delegate == nil {
      activityUpdateCell.delegate = self
    } else if let FBConnectCell = cell as? FindFriendsFacebookConnectCell
      where FBConnectCell.delegate == nil {
      FBConnectCell.delegate = self
    } else if let findFriendsCell = cell as? FindFriendsHeaderCell
      where findFriendsCell.delegate == nil {
      findFriendsCell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let activity = self.dataSource[indexPath] as? Activity else {
      return
    }

    self.viewModel.inputs.tappedActivity(activity)
  }

  @IBAction internal func refresh() {
    self.viewModel.inputs.refresh()
  }

  private func present(project project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController.")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func goToFriends(source source: FriendsSource) {
    guard let friendVC = UIStoryboard(name: "Friends", bundle: nil)
      .instantiateInitialViewController() as? FindFriendsViewController else {
      fatalError("Could not instantiate FindFriendsViewController.")
    }

    friendVC.configureWith(source: .activity)
    self.navigationController?.pushViewController(friendVC, animated: true)
  }

  private func deleteFacebookSection() {
    self.tableView.beginUpdates()

    self.tableView.deleteRowsAtIndexPaths(self.dataSource.removeFacebookConnectRows(), withRowAnimation: .Top)

    self.tableView.endUpdates()
  }

  private func deleteFindFriendsSection() {
    self.tableView.beginUpdates()

    self.tableView.deleteRowsAtIndexPaths(self.dataSource.removeFindFriendsRows(), withRowAnimation: .Top)

    self.tableView.endUpdates()
  }
}

extension ActivitiesViewController: ActivityUpdateCellDelegate {
  internal func activityUpdateCellTappedProjectImage(activity activity: Activity) {
    self.viewModel.inputs.activityUpdateCellTappedProjectImage(activity: activity)
  }
}

extension ActivitiesViewController: FindFriendsHeaderCellDelegate {
  func findFriendsHeaderCellDismissHeader() {
    self.viewModel.inputs.findFriendsHeaderCellDismissHeader()
  }

  func findFriendsHeaderCellGoToFriends() {
    self.viewModel.inputs.findFriendsHeaderCellGoToFriends()
  }
}

extension ActivitiesViewController: FindFriendsFacebookConnectCellDelegate {
  func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    self.viewModel.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()
  }

  func findFriendsFacebookConnectCellDidDismissHeader() {
    self.viewModel.inputs.findFriendsFacebookConnectCellDidDismissHeader()
  }

  func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError) {
    self.viewModel.inputs.findFriendsFacebookConnectCellShowErrorAlert(alert)
  }
}
