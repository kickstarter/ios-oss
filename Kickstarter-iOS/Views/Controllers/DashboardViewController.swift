import KsApi
import Library
import UIKit
import Prelude
import Prelude_UIKit

internal final class DashboardViewController: UITableViewController {
  @IBOutlet private weak var titleView: DashboardTitleView!
  @IBOutlet private weak var shareButton: UIBarButtonItem!

  private let dataSource = DashboardDataSource()
  private let viewModel: DashboardViewModelType = DashboardViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal static func instantiate() -> DashboardViewController {
    return Storyboard.Dashboard.instantiate(DashboardViewController)
  }

  internal func `switch`(toProject param: Param) {
    self.viewModel.inputs.`switch`(toProject: param)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    let shareButton = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(DashboardViewController.shareButtonTapped))

    self.navigationItem.rightBarButtonItem = shareButton

    self.titleView.delegate = self
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func bindStyles() {
    self |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.fundingData
      .observeForUI()
      .observeNext { [weak self] stats, project in
        self?.dataSource.load(fundingDateStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.project
      .observeForUI()
      .observeNext { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()

        // NB: this is just temporary for now
        self?.shareViewModel.inputs.configureWith(shareContext: .creatorDashboard(project))
    }

    self.viewModel.outputs.referrerData
      .observeForUI()
      .observeNext { [weak self] (cumulative, project, referrers) in
        self?.dataSource.load(cumulative: cumulative, project: project, referrers: referrers)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.rewardData
      .observeForUI()
      .observeNext { [weak self] (stats, project) in
        self?.dataSource.load(rewardStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.videoStats
      .observeForUI()
      .observeNext { [weak self] videoStats in
        self?.dataSource.load(videoStats: videoStats)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentProjectsDrawer
      .observeForControllerAction()
      .observeNext { [weak self] data in
        self?.presentProjectsDrawer(data: data)
    }

    self.viewModel.outputs.animateOutProjectsDrawer
      .observeForControllerAction()
      .observeNext { [weak self] in
        if let drawerVC = self?.presentedViewController as? DashboardProjectsDrawerViewController {
          drawerVC.animateOut()
        }
    }

    self.viewModel.outputs.dismissProjectsDrawer
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(false, completion: nil)
    }

    self.viewModel.outputs.updateTitleViewData
      .observeForControllerAction()
      .observeNext { [weak element = self.titleView] data in
        element?.updateData(data)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] project, projects, reftag in
        self?.goToProject(project, projects: projects, refTag: reftag)
    }

    self.viewModel.outputs.focusScreenReaderOnTitleView
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.accessibilityFocusOnTitleView()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }
  }
  // swiftlint:enable function_body_length

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {
    if let actionCell = cell as? DashboardActionCell {
      actionCell.delegate = self
    } else if let referrersCell = cell as? DashboardReferrersCell {
      referrersCell.delegate = self
    } else if let rewardsCell = cell as? DashboardRewardsCell {
      rewardsCell.delegate = self
    }
  }

  private func goToActivity(project: Project) {
    let vc = ProjectActivitiesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let _ = cell as? DashboardContextCell {
      self.viewModel.inputs.projectContextCellTapped()
    }
  }

  private func goToMessages(project: Project) {
    let vc = MessageThreadsViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToPostUpdate(project: Project) {
    let vc = UpdateDraftViewController.configuredWith(project: project)
    vc.delegate = self

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToProject(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func presentProjectsDrawer(data data: [ProjectsDrawerData]) {
    let vc = DashboardProjectsDrawerViewController.configuredWith(data: data)
    vc.delegate = self
    self.modalPresentationStyle = .OverCurrentContext
    self.presentViewController(vc, animated: false, completion: nil)
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.presentViewController(controller, animated: true, completion: nil)

    } else {
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  private func accessibilityFocusOnTitleView() {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.titleView)
  }

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }
}

extension DashboardViewController: DashboardActionCellDelegate {
  internal func goToActivity(cell: DashboardActionCell?, project: Project) {
    self.goToActivity(project)
  }

  internal func goToMessages(cell: DashboardActionCell?, project: Project) {
    self.goToMessages(project)
  }

  internal func goToPostUpdate(cell: DashboardActionCell?, project: Project) {
    self.goToPostUpdate(project)
  }
}

extension DashboardViewController: UpdateDraftViewControllerDelegate {
  func updateDraftViewControllerWantsDismissal(updateDraftViewController: UpdateDraftViewController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension DashboardViewController: DashboardReferrersCellDelegate {
  func dashboardReferrersCellDidAddReferrerRows(cell: DashboardReferrersCell?) {
    let inset = self.tableView.contentInset
    self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 1000, right: 0.0)

    self.tableView.beginUpdates()
    self.tableView.endUpdates()

    self.tableView.contentInset = inset
  }
}

extension DashboardViewController: DashboardRewardsCellDelegate {
  func dashboardRewardsCellDidAddRewardRows(cell: DashboardRewardsCell?) {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

extension DashboardViewController: DashboardProjectsDrawerViewControllerDelegate {
  func dashboardProjectsDrawerCellDidTapProject(project: Project) {
    self.viewModel.inputs.`switch`(toProject: .id(project.id))
  }

  func dashboardProjectsDrawerDidAnimateOut() {
    self.viewModel.inputs.dashboardProjectsDrawerDidAnimateOut()
  }

  func dashboardProjectsDrawerHideDrawer() {
    self.viewModel.inputs.showHideProjectsDrawer()
  }
}

extension DashboardViewController: DashboardTitleViewDelegate {
  func dashboardTitleViewShowHideProjectsDrawer() {
    self.viewModel.inputs.showHideProjectsDrawer()
  }
}

extension DashboardViewController: ProjectNavigatorDelegate {
}
