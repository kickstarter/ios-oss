import Foundation
import UIKit
import KsApi
import Library
import ReactiveCocoa
import Result
import Prelude

internal final class CommentsViewController: UITableViewController {
  private let viewModel: CommentsViewModelType = CommentsViewModel()
  private let dataSource = CommentsDataSource()

  @IBOutlet internal weak var commentBarButton: UIBarButtonItem!
  private weak var loginToutViewController: UIViewController? = nil

  internal static func configuredWith(project project: Project? = nil, update: Update? = nil)
    -> CommentsViewController {

      let vc = Storyboard.Comments.instantiate(CommentsViewController)
      vc.viewModel.inputs.project(project, update: update)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    self.tableView
      |> UITableView.lens.allowsSelection .~ false
      |> UITableView.lens.estimatedRowHeight .~ 200.0
      |> UITableView.lens.rowHeight .~ UITableViewAutomaticDimension
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    self.viewModel.outputs.dataSource
      .observeForControllerAction()
      .observeNext { [weak self] comments, project, user in
        self?.dataSource.load(comments: comments, project: project, loggedInUser: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.backerEmptyStateVisible
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.dataSource.backerEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.loggedOutEmptyStateVisible
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.dataSource.loggedOutEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.nonBackerEmptyStateVisible
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.dataSource.nonBackerEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.commentButtonVisible
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.navigationItem.rightBarButtonItem = visible ? self?.commentBarButton : nil
    }

    self.viewModel.outputs.presentPostCommentDialog
      .observeForControllerAction()
      .observeNext { [weak self] project, update in
        self?.presentCommentDialog(project: project, update: update)
    }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in self?.presentLoginTout() }

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.commentsAreLoading
      .observeForControllerAction()
      .observeNext { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
    }
  }
  // swiftlint:enable function_body_length

  override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                          forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal func presentCommentDialog(project project: Project, update: Update?) {
    let dialog = CommentDialogViewController
      .configuredWith(project: project, update: update, recipient: nil,
                      context: update == nil ? .projectComments : .updateComments)
    dialog.modalPresentationStyle = .FormSheet
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  internal func presentLoginTout() {
    let login = LoginToutViewController.configuredWith(loginIntent: .generic)
    self.presentViewController(UINavigationController(rootViewController: login),
                               animated: true,
                               completion: nil)
  }

  @IBAction func commentButtonPressed() {
    self.viewModel.inputs.commentButtonPressed()
  }

  @IBAction internal func refresh() {
    self.viewModel.inputs.refresh()
  }

  @IBAction func emptyStateLoginButtonPressed() {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction func emptyStateBecomeABackerButtonPressed() {
    self.viewModel.inputs.backProjectButtonPressed()
  }

  @IBAction func emptyStateCommentButtonPressed() {
    self.viewModel.inputs.commentButtonPressed()
  }
}

extension CommentsViewController: CommentDialogDelegate {

  internal func commentDialogWantsDismissal(dialog: CommentDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func commentDialog(dialog: CommentDialogViewController, postedComment comment: Comment) {
    self.viewModel.inputs.commentPosted(comment)
  }
}
