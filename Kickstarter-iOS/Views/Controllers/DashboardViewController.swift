import KsApi
import Library
import UIKit
import Prelude
import Prelude_UIKit

internal final class DashboardViewController: UITableViewController {
  @IBOutlet weak var titleView: DashboardTitleView!
  @IBOutlet weak var shareButton: UIBarButtonItem!

  private let dataSource = DashboardDataSource()
  private let viewModel: DashboardViewModelType = DashboardViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    let shareButton = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(DashboardViewController.shareButtonTapped))

    self.navigationItem.rightBarButtonItem = shareButton

    self.titleView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func bindStyles() {
    self |> baseTableControllerStyle(estimatedRowHeight: 200.0)
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
      .observeForUI()
      .observeNext { [weak self] data in
        self?.presentProjectsDrawer(data: data)
    }

    self.viewModel.outputs.animateOutProjectsDrawer
      .observeForUI()
      .observeNext { [weak self] in
        if let drawerVC = self?.presentedViewController as? DashboardProjectsDrawerViewController {
          drawerVC.animateOut()
        }
    }

    self.viewModel.outputs.dismissProjectsDrawer
      .observeForUI()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(false, completion: nil)
    }

    self.viewModel.outputs.updateTitleViewData
      .observeForUI()
      .observeNext { [weak element = self.titleView] data in
        element?.updateData(data)
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] (project, reftag) in
        self?.goToProject(project, refTag: reftag)
    }

    self.viewModel.outputs.focusScreenReaderOnTitleView
      .observeForUI()
      .observeNext { [weak self] in
        self?.accessibilityFocusOnTitleView()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
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
    guard let vc = UIStoryboard(name: "ProjectActivity", bundle: .framework)
      .instantiateInitialViewController() as? ProjectActivitiesViewController else {
        fatalError("Could not instantiate ProjectActivitiesViewController.")
    }

    vc.configureWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let _ = cell as? DashboardContextCell {
      self.viewModel.inputs.projectContextCellTapped()
    }
  }

  private func goToMessages(project: Project) {
    guard let vc = UIStoryboard(name: "Messages", bundle: .framework).instantiateInitialViewController(),
      messages = vc as? MessageThreadsViewController else {
        fatalError("Could not instantiate MessageThreadsViewController.")
    }

    messages.configureWith(project: project)
    self.navigationController?.pushViewController(messages, animated: true)
  }

  private func goToPostUpdate(project: Project) {
    guard let vc = UIStoryboard(name: "UpdateDraft", bundle: .framework).instantiateInitialViewController()
      as? UpdateDraftViewController else {
        fatalError("Could not instantiate DraftViewController.")
    }

    vc.configureWith(project: project)
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func goToProject(project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: .framework).instantiateInitialViewController()
      as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController.")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func presentProjectsDrawer(data data: [ProjectsDrawerData]) {
    guard let drawerVC = UIStoryboard(name: "DashboardProjectsDrawer", bundle: .framework)
      .instantiateInitialViewController() as? DashboardProjectsDrawerViewController else {
        fatalError("Could not instantiate DashboardProjectsDrawerViewController.")
    }
    drawerVC.configureWith(data: data)
    drawerVC.delegate = self
    self.modalPresentationStyle = .OverCurrentContext
    self.presentViewController(drawerVC, animated: false, completion: nil)
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
    self.viewModel.inputs.dashboardProjectsDrawerSwitchToProject(project)
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
