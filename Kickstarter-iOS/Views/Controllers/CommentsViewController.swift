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

  internal func configureWith(project project: Project? = nil, update: Update? = nil) {
    self.viewModel.inputs.project(project, update: update)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()

    self.tableView.estimatedRowHeight = 200.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    self.viewModel.outputs.dataSource
      .observeForUI()
      .observeNext { [weak self] comments, project, user in
        self?.dataSource.load(comments: comments, project: project, loggedInUser: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.backerEmptyStateVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.backerEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.loggedOutEmptyStateVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.loggedOutEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.nonBackerEmptyStateVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.nonBackerEmptyState(visible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.commentButtonVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.navigationItem.rightBarButtonItem = visible ? self?.commentBarButton : nil
    }

    self.viewModel.outputs.presentPostCommentDialog
      .observeForUI()
      .observeNext { [weak self] project, update in
        self?.presentCommentDialog(project: project, update: update)
    }

    self.viewModel.outputs.openLoginTout
      .observeForUI()
      .observeNext { [weak self] in self?.presentLoginTout() }

    self.viewModel.outputs.closeLoginTout
      .observeForUI()
      .observeNext { [weak self] in
        self?.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.commentsAreLoading
      .observeForUI()
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
    guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CommentDialogViewController"),
      dialog = vc as? CommentDialogViewController else {
        fatalError("Could not instantiate CommentDialogViewController.")
    }

    dialog.modalPresentationStyle = .FormSheet
    dialog.configureWith(project: project, update: update)
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  internal func presentLoginTout() {
    let vc = UIStoryboard(name: "Login", bundle: nil)
      .instantiateViewControllerWithIdentifier("LoginToutViewController")
    guard let login = vc as? LoginToutViewController else {
        fatalError("Could not instantiate LoginToutViewController.")
    }

    self.loginToutViewController = vc
    login.configureWith(loginIntent: .generic)
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
