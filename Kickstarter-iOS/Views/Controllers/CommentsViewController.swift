import Foundation
import UIKit
import KsApi
import Library
import ReactiveSwift
import Result
import Prelude

internal final class CommentsViewController: UITableViewController {
  fileprivate let viewModel: CommentsViewModelType = CommentsViewModel()
  fileprivate let dataSource = CommentsDataSource()

  // This button needs to store a strong reference so as to not get wiped when setting hidden state.
  @IBOutlet fileprivate var commentBarButton: UIBarButtonItem!
  fileprivate weak var loginToutViewController: UIViewController?

  internal static func configuredWith(project: Project? = nil, update: Update? = nil)
    -> CommentsViewController {

      let vc = Storyboard.Comments.instantiate(CommentsViewController.self)
      vc.viewModel.inputs.configureWith(project: project, update: update)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    if self.traitCollection.userInterfaceIdiom == .pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    _ = self.commentBarButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_comment() }
      |> UIBarButtonItem.lens.accessibilityHint %~ { _ in
        Strings.accessibility_dashboard_buttons_post_update_hint()
    }
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.loginToutViewController?.dismiss(animated: true, completion: nil)
    }

    self.viewModel.outputs.commentBarButtonVisible
      .observeForUI()
      .observeValues { [weak self] visible in
        self?.navigationItem.rightBarButtonItem = visible ? self?.commentBarButton : nil
    }

    self.viewModel.outputs.commentsAreLoading
      .observeForUI()
      .observeValues { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
    }

    self.viewModel.outputs.dataSource
      .observeForUI()
      .observeValues { [weak self] comments, project, update, user, shouldShowEmptyState in
        self?.dataSource.load(comments: comments,
                              project: project,
                              update: update,
                              loggedInUser: user,
                              shouldShowEmptyState: shouldShowEmptyState)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in self?.presentLoginTout() }

    self.viewModel.outputs.presentPostCommentDialog
      .observeForControllerAction()
      .observeValues { [weak self] project, update in
        self?.presentCommentDialog(project: project, update: update)
    }
  }
  // swiftlint:enable function_body_length

  override func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {

    if let emptyCell = cell as? CommentsEmptyStateCell {
      emptyCell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal func presentCommentDialog(project: Project, update: Update?) {
    let dialog = CommentDialogViewController
      .configuredWith(project: project, update: update, recipient: nil,
                      context: update == nil ? .projectComments : .updateComments)
    dialog.delegate = self
    let nav = UINavigationController(rootViewController: dialog)
    nav.modalPresentationStyle = .formSheet
    self.present(nav, animated: true, completion: nil)
  }

  internal func presentLoginTout() {
    let login = LoginToutViewController.configuredWith(loginIntent: .generic)
    let nav = UINavigationController(rootViewController: login)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  @IBAction func commentButtonPressed() {
    self.viewModel.inputs.commentButtonPressed()
  }

  @IBAction internal func refresh() {
    self.viewModel.inputs.refresh()
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension CommentsViewController: CommentDialogDelegate {
  internal func commentDialogWantsDismissal(_ dialog: CommentDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func commentDialog(_ dialog: CommentDialogViewController, postedComment comment: Comment) {
    self.viewModel.inputs.commentPosted(comment)
  }
}

extension CommentsViewController: CommentsEmptyStateCellDelegate {
  internal func commentEmptyStateCellGoBackToProject() {
    _ = self.navigationController?.popViewController(animated: true)
  }

  internal func commentEmptyStateCellGoToCommentDialog() {
    self.viewModel.inputs.commentButtonPressed()
  }

  internal func commentEmptyStateCellGoToLoginTout() {
    self.viewModel.inputs.loginButtonPressed()
  }
}
