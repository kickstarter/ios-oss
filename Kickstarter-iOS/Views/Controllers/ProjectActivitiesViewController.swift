import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectActivitiesViewController: UITableViewController {
  private let viewModel: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()
  private let dataSource = ProjectActivitiesDataSource()

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()

    self |> baseTableControllerStyle(estimatedRowHeight: 300.0)
    self.tableView.dataSource = dataSource
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activitiesAndProject
      .observeForUI()
      .observeNext { [weak self] activities, project in
        self?.dataSource.load(activities: activities, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goTo
      .observeForUI()
      .observeNext { [weak self] goTo in
        switch goTo {
        case let .backing(project, user):
          self?.goToBacking(project: project, user: user)
        case let .comments(project, update):
          self?.goToComments(project: project, update: update)
        case let .project(project):
          self?.goToProject(project: project)
        case let .sendReplyOnProject(project, comment):
          self?.goToSendReplyOnProject(project: project, comment: comment)
        case let .sendReplyOnUpdate(update, comment):
          self?.goToSendReplyOnUpdate(update: update, comment: comment)
        case let .sendMessage(project, backing):
          self?.goToSendMessage(project: project, backing: backing)
        case let .update(project, update):
          self?.goToUpdate(project: project, update: update)
        }
    }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ProjectActivityBackingCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectActivityCommentCell where cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  override internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let (activity, project) = self.dataSource.activityAndProjectAtIndexPath(indexPath) else { return }
    self.viewModel.inputs.activityAndProjectCellTapped(activity: activity, project: project)
  }

  internal func goToBacking(project project: Project, user: User) {
    guard let vc = UIStoryboard(name: "Backing", bundle: .framework).instantiateInitialViewController()
      as? BackingViewController else {
        fatalError("Could not instantiate BackingViewController.")
    }

    vc.configureWith(project: project, backer: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func goToComments(project project: Project, update: Update?) {
    guard let vc = UIStoryboard(name: "Comments", bundle: .framework).instantiateInitialViewController()
      as? CommentsViewController else {
        fatalError("Could not instantiate CommentsViewController.")
    }

    vc.configureWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func goToProject(project project: Project) {
    guard let vc = UIStoryboard(name: "Project", bundle: .framework).instantiateInitialViewController()
      as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController.")
    }

    vc.configureWith(project: project, refTag: RefTag.dashboard)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  internal func goToSendMessage(project project: Project, backing: Backing) {
  }

  internal func goToSendReplyOnProject(project project: Project, comment: Comment) {
  }

  internal func goToSendReplyOnUpdate(update update: Update, comment: Comment) {
  }

  internal func goToUpdate(project project: Project, update: Update) {
    guard let vc = UIStoryboard(name: "Update", bundle: .framework)
      .instantiateViewControllerWithIdentifier("UpdateViewController") as? UpdateViewController else {
        fatalError("Could not instantiate UpdateViewController")
    }

    vc.configureWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension ProjectActivitiesViewController: ProjectActivityBackingCellDelegate {
  func projectActivityBackingCellGoToBacking(project project: Project, user: User) {
    self.viewModel.inputs.projectActivityBackingCellGoToBacking(project: project, user: user)
  }

  func projectActivityBackingCellGoToSendMessage(project project: Project, backing: Backing) {
    self.viewModel.inputs.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
  }
}

extension ProjectActivitiesViewController: ProjectActivityCommentCellDelegate {
  func projectActivityCommentCellGoToBacking(project project: Project, user: User) {
    self.viewModel.inputs.projectActivityCommentCellGoToBacking(project: project, user: user)
  }

  func projectActivityCommentCellGoToSendReplyOnProject(project project: Project, comment: Comment) {
    self.viewModel.inputs.projectActivityCommentCellGoToSendReplyOnProject(project: project, comment: comment)
  }

  func projectActivityCommentCellGoToSendReplyOnUpdate(update update: Update, comment: Comment) {
    self.viewModel.inputs.projectActivityCommentCellGoToSendReplyOnUpdate(update: update, comment: comment)
  }
}
