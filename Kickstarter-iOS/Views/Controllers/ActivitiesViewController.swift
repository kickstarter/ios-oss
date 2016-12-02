import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivitiesViewController: UITableViewController {
  private let viewModel: ActivitiesViewModelType = ActivitiesViewModel()
  private let dataSource = ActivitiesDataSource()

  private var emptyStatesController: EmptyStatesViewController?

  internal static func instantiate() -> ActivitiesViewController {
    return Storyboard.Activity.instantiate(ActivitiesViewController)
  }

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

  internal override func viewDidLayoutSubviews() {
    self.emptyStatesController?.view.frame = self.view.bounds
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource

    let emptyVC = EmptyStatesViewController.configuredWith(emptyState: .activity)
    self.emptyStatesController = emptyVC
    emptyVC.delegate = self
    self.addChildViewController(emptyVC)
    self.view.addSubview(emptyVC.view)
    emptyVC.didMoveToParentViewController(self)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 80.0)

    self.navigationItem
      |> UINavigationItem.lens.title %~ { _ in Strings.activity_navigation_title_activity() }

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
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

    self.viewModel.outputs.showEmptyStateIsLoggedIn
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.tableView.bounces = false
        if let emptyVC = self?.emptyStatesController {
          self?.emptyStatesController?.view.hidden = false
          self?.view.bringSubviewToFront(emptyVC.view)
        }
    }

    self.viewModel.outputs.hideEmptyState
      .observeForUI()
      .observeNext { [weak self] in
        self?.tableView.bounces = true
        self?.emptyStatesController?.view.hidden = true
    }

    self.refreshControl?.rac.refreshing = self.viewModel.outputs.isRefreshing

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
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
      .observeForControllerAction()
      .observeNext { [weak self] source in
        self?.goToFriends(source: source)
    }

    self.viewModel.outputs.showFacebookConnectErrorAlert
      .observeForControllerAction()
      .observeNext { [weak self] error in
        self?.presentViewController(
          UIAlertController.alertController(forError: error),
          animated: true,
          completion: nil
        )
    }

    self.viewModel.outputs.unansweredSurveyResponse
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.load(surveyResponse: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToSurveyResponse
      .observeForControllerAction()
      .observeNext { [weak self] surveyResponse in
        self?.goToSurveyResponse(surveyResponse: surveyResponse)
    }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeNext { [weak self] project, update in
        self?.goToUpdate(project: project, update: update)
    }
  }
  // swiftlint:enable function_body_length

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ActivityUpdateCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? FindFriendsFacebookConnectCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? FindFriendsHeaderCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivitySurveyResponseCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivityFriendFollowCell where cell.delegate == nil {
      cell.delegate = self
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

    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goToFriends(source source: FriendsSource) {
    let vc = FindFriendsViewController.configuredWith(source: .activity)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToSurveyResponse(surveyResponse surveyResponse: SurveyResponse) {
    let vc = SurveyResponseViewController.configuredWith(surveyResponse: surveyResponse)
    vc.delegate = self

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToUpdate(project project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
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

extension ActivitiesViewController: ActivitySurveyResponseCellDelegate {
  func activityTappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse) {
    self.viewModel.inputs.tappedRespondNow(forSurveyResponse: surveyResponse)
  }
}

extension ActivitiesViewController: ActivityFriendFollowCellDelegate {
  func activityFriendFollowCell(cell: ActivityFriendFollowCell, updatedActivity: Activity) {
    self.viewModel.inputs.updateActivity(updatedActivity)
  }
}

extension ActivitiesViewController: EmptyStatesViewControllerDelegate {
  func emptyStatesViewController(viewController: EmptyStatesViewController,
                                 goToDiscoveryWithParams params: DiscoveryParams?) {

    guard let tabController = self.tabBarController as? RootTabBarViewController else { return }
    tabController.switchToDiscovery(params: params)
  }

  func emptyStatesViewControllerGoToFriends() {}
}

extension ActivitiesViewController: SurveyResponseViewControllerDelegate {
  func surveyResponseViewControllerDismissed() {
    self.viewModel.inputs.surveyResponseViewControllerDismissed()
  }
}
