import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectActivitiesViewController: UITableViewController {
  private let viewModel: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()
  private let dataSource = ProjectActivitiesDataSource()

  internal static func configuredWith(project project: Project) -> ProjectActivitiesViewController {
    let vc = Storyboard.ProjectActivity.instantiate(ProjectActivitiesViewController)
    vc.viewModel.inputs.configureWith(project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle

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
      .observeForControllerAction()
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

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    self.navigationController
      ?|> UINavigationController.lens.navigationBar.barTintColor .~ .whiteColor()

    self.title = Strings.activity_navigation_title_activity()
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
    let vc = BackingViewController.configuredWith(project: project, backer: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func goToComments(project project: Project, update: Update?) {
    let vc = CommentsViewController.configuredWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func goToProject(project project: Project) {
    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project),
                                                          refTag: .dashboardActivity)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  internal func goToSendMessage(backing backing: Backing,
                                        context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: .backing(backing), context: context)
    vc.modalPresentationStyle = .FormSheet
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  internal func goToSendReply(project project: Project, update: Update?, comment: Comment) {
    let dialog = CommentDialogViewController
      .configuredWith(project: project, update: update, recipient: comment.author, context: .projectActivity)
    dialog.modalPresentationStyle = .FormSheet
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  internal func goToUpdate(project project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update)
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
