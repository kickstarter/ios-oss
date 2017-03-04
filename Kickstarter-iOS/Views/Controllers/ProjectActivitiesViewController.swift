import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectActivitiesViewController: UITableViewController {
  fileprivate let viewModel: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()
  fileprivate let dataSource = ProjectActivitiesDataSource()

  private let navBorder = UIView()

  internal static func configuredWith(project: Project) -> ProjectActivitiesViewController {
    let vc = Storyboard.ProjectActivity.instantiate(ProjectActivitiesViewController.self)
    vc.viewModel.inputs.configureWith(project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    if let navBar = self.navigationController?.navigationBar {
      _ = self.navBorder |> baseNavigationBorderStyle(navBar: navBar)
      navBar.addSubview(navBorder)
    }

    self.tableView.dataSource = dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let navBar = self.navigationController?.navigationBar {
      self.navBorder.frame = CGRect(x: 0.0,
                                    y: navBar.frame.size.height,
                                    width: navBar.frame.size.width,
                                    height: self.navBorder.frame.size.height)
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectActivityData
      .observeForUI()
      .observeValues { [weak self] projectActivityData in
        self?.dataSource.load(projectActivityData: projectActivityData)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goTo
      .observeForControllerAction()
      .observeValues { [weak self] goTo in
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
      .observeValues { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.tableView.reloadData()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle

    self.title = Strings.activity_navigation_title_activity()
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    if let cell = cell as? ProjectActivityBackingCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectActivityCommentCell, cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  override internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let (activity, project) = self.dataSource.activityAndProjectAtIndexPath(indexPath) else { return }
    self.viewModel.inputs.activityAndProjectCellTapped(activity: activity, project: project)
  }

  internal func goToBacking(project: Project, user: User) {
    let vc = BackingViewController.configuredWith(project: project, backer: user)
    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  internal func goToComments(project: Project?, update: Update?) {
    let vc = CommentsViewController.configuredWith(project: project, update: update)
    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  internal func goToProject(project: Project) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: .dashboardActivity)
    self.present(vc, animated: true, completion: nil)
  }

  internal func goToSendMessage(backing: Backing,
                                context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: .backing(backing), context: context)
    vc.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  internal func goToSendReply(project: Project, update: Update?, comment: Comment) {
    let dialog = CommentDialogViewController
      .configuredWith(project: project, update: update, recipient: comment.author, context: .projectActivity)
    dialog.modalPresentationStyle = .formSheet
    dialog.delegate = self
    self.present(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  internal func goToUpdate(project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update, context: .creatorActivity)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension ProjectActivitiesViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}

extension ProjectActivitiesViewController: ProjectActivityBackingCellDelegate {
  internal func projectActivityBackingCellGoToBacking(project: Project, user: User) {
    self.viewModel.inputs.projectActivityBackingCellGoToBacking(project: project, user: user)
  }

  internal func projectActivityBackingCellGoToSendMessage(project: Project, backing: Backing) {
    self.viewModel.inputs.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
  }
}

extension ProjectActivitiesViewController: ProjectActivityCommentCellDelegate {
  internal func projectActivityCommentCellGoToBacking(project: Project, user: User) {
    self.viewModel.inputs.projectActivityCommentCellGoToBacking(project: project, user: user)
  }

  func projectActivityCommentCellGoToSendReply(project: Project, update: Update?, comment: Comment) {
    self.viewModel.inputs.projectActivityCommentCellGoToSendReply(project: project,
                                                                  update: update,
                                                                  comment: comment)
  }
}

extension ProjectActivitiesViewController: CommentDialogDelegate {
  internal func commentDialogWantsDismissal(_ dialog: CommentDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func commentDialog(_ dialog: CommentDialogViewController, postedComment: Comment) {
  }
}
