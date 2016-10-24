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

  // This button needs to store a strong reference so as to not get wiped when setting hidden state.
  @IBOutlet private var commentBarButton: UIBarButtonItem!
  private weak var loginToutViewController: UIViewController? = nil

  internal static func configuredWith(project project: Project? = nil, update: Update? = nil)
    -> CommentsViewController {

      let vc = Storyboard.Comments.instantiate(CommentsViewController)
      vc.viewModel.inputs.configureWith(project: project, update: update)
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

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    if self.traitCollection.userInterfaceIdiom == .Pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> CommentsViewController.lens.view.backgroundColor .~ .whiteColor()

    self.commentBarButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_comment() }
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.general_navigation_buttons_comment() }
      |> UIBarButtonItem.lens.accessibilityHint %~ { _ in
        Strings.accessibility_dashboard_buttons_post_update_hint()
    }
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.commentBarButtonVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.navigationItem.rightBarButtonItem = visible ? self?.commentBarButton : nil
    }

    self.viewModel.outputs.commentsAreLoading
      .observeForUI()
      .observeNext { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
    }

    self.viewModel.outputs.dataSource
      .observeForUI()
      .observeNext { [weak self] comments, project, user in
        self?.dataSource.load(comments: comments, project: project, loggedInUser: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.emptyStateVisible
      .observeForControllerAction()
      .observeNext { [weak self] project, update in
        self?.dataSource.load(project: project, update: update)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in self?.presentLoginTout() }

    self.viewModel.outputs.presentPostCommentDialog
      .observeForControllerAction()
      .observeNext { [weak self] project, update in
        self?.presentCommentDialog(project: project, update: update)
    }
  }
  // swiftlint:enable function_body_length

  override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                          forRowAtIndexPath indexPath: NSIndexPath) {

    if let emptyCell = cell as? CommentsEmptyStateCell {
      emptyCell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal func presentCommentDialog(project project: Project, update: Update?) {
    let dialog = CommentDialogViewController
      .configuredWith(project: project, update: update, recipient: nil,
                      context: update == nil ? .projectComments : .updateComments)
    dialog.delegate = self
    let nav = UINavigationController(rootViewController: dialog)
    nav.modalPresentationStyle = .FormSheet
    self.presentViewController(nav, animated: true, completion: nil)
  }

  internal func presentLoginTout() {
    let login = LoginToutViewController.configuredWith(loginIntent: .generic)
    let nav = UINavigationController(rootViewController: login)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }

  @IBAction func commentButtonPressed() {
    self.viewModel.inputs.commentButtonPressed()
  }

  @IBAction internal func refresh() {
    self.viewModel.inputs.refresh()
  }

  @objc private func closeButtonTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
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

extension CommentsViewController: CommentsEmptyStateCellDelegate {
  internal func commentEmptyStateCellGoToCommentDialog() {
    self.viewModel.inputs.commentButtonPressed()
  }

  internal func commentEmptyStateCellGoToLoginTout() {
    self.viewModel.inputs.loginButtonPressed()
  }
}
