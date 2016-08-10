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

    self.viewModel.outputs.projectActivityData
      .observeForUI()
      .observeNext { [weak self] projectActivityData in
        self?.dataSource.load(projectActivityData: projectActivityData)
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
        case let .sendReply(project, update, comment):
          self?.goToSendReply(project: project, update: update, comment: comment)
        case let .sendMessage(backing, context):
          self?.goToSendMessage(backing: backing, context: context)
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
    let vc = UIStoryboard(name: "ProjectMagazine", bundle: .framework)
      .instantiateViewControllerWithIdentifier("ProjectMagazineViewController")
    guard let projectViewController = vc as? ProjectMagazineViewController else {
      fatalError("Couldn't instantiate project view controller.")
    }

    projectViewController.configureWith(project: project, refTag: .dashboard)
    let nav = UINavigationController(rootViewController: projectViewController)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  internal func goToSendMessage(backing backing: Backing,
                                        context: Koala.MessageDialogContext) {
    guard let vc = UIStoryboard(name: "Messages", bundle: .framework)
      .instantiateViewControllerWithIdentifier("MessageDialogViewController") as? MessageDialogViewController
      else {
        fatalError("Couldn’t instantiate MessageDialogViewController.")
    }

    vc.configureWith(messageSubject: MessageSubject.backing(backing), context: context)
    vc.modalPresentationStyle = .FormSheet
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  internal func goToSendReply(project project: Project, update: Update?, comment: Comment) {
    guard let dialog = UIStoryboard(name: "Comments", bundle: .framework)
      .instantiateViewControllerWithIdentifier("CommentDialogViewController") as? CommentDialogViewController
      else {
        fatalError("Could not instantiate CommentDialogViewController.")
    }

    dialog.modalPresentationStyle = .FormSheet
    dialog.configureWith(project: project, update: update, recipient: comment.author,
                         context: .projectActivity)
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
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

extension ProjectActivitiesViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}

extension ProjectActivitiesViewController: ProjectActivityBackingCellDelegate {
  internal func projectActivityBackingCellGoToBacking(project project: Project, user: User) {
    self.viewModel.inputs.projectActivityBackingCellGoToBacking(project: project, user: user)
  }

  internal func projectActivityBackingCellGoToSendMessage(project project: Project, backing: Backing) {
    self.viewModel.inputs.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
  }
}

extension ProjectActivitiesViewController: ProjectActivityCommentCellDelegate {
  internal func projectActivityCommentCellGoToBacking(project project: Project, user: User) {
    self.viewModel.inputs.projectActivityCommentCellGoToBacking(project: project, user: user)
  }

  func projectActivityCommentCellGoToSendReply(project project: Project, update: Update?, comment: Comment) {
    self.viewModel.inputs.projectActivityCommentCellGoToSendReply(project: project,
                                                                  update: update,
                                                                  comment: comment)
  }
}

extension ProjectActivitiesViewController: CommentDialogDelegate {
  internal func commentDialogWantsDismissal(dialog: CommentDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func commentDialog(dialog: CommentDialogViewController, postedComment: Comment) {
  }
}
