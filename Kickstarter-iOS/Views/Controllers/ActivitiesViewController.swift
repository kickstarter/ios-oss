import Foundation
import Library
import UIKit
import ReactiveCocoa
import Models

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
    self.tableView.dataSource = dataSource
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .observeNext { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    Signal.merge(
      self.viewModel.outputs.showLoggedOutEmptyState,
      self.viewModel.outputs.showLoggedInEmptyState
      )
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
    }

    self.viewModel.outputs.isRefreshing
      .observeForUI()
      .observeNext { [weak control = self.refreshControl] in
        $0 ? control?.beginRefreshing() : control?.endRefreshing()
    }

    self.viewModel.outputs.showProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.present(project: project, refTag: refTag)
    }
  }

  internal override func tableView(tableView: UITableView,
                          estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  internal override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                                          forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ActivityUpdateCell where cell.delegate == nil {
      cell.delegate = self.viewModel.inputs
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let activity = self.dataSource[indexPath] as? Activity else {
      return
    }

    if let project = activity.project where activity.category == .Backing {
      present(project: project, refTag: RefTag.activity)
    }
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
}
