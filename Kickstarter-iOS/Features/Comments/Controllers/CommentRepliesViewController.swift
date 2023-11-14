import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Composer {
    static let originalHeight: CGFloat = 80.0
  }
}

final class CommentRepliesViewController: UITableViewController, MessageBannerViewControllerPresenting {
  // MARK: Properties

  private let dataSource = CommentRepliesDataSource()
  internal let viewModel: CommentRepliesViewModelType = CommentRepliesViewModel()

  public var messageBannerViewController: MessageBannerViewController?

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  // MARK: - Accessors

  internal static func configuredWith(
    comment: Comment,
    project: Project,
    update: Update?,
    inputAreaBecomeFirstResponder: Bool,
    replyId: String?
  ) -> CommentRepliesViewController {
    let vc = CommentRepliesViewController.instantiate()
    vc.viewModel.inputs.configureWith(
      comment: comment,
      project: project,
      update: update,
      inputAreaBecomeFirstResponder: inputAreaBecomeFirstResponder,
      replyId: replyId
    )

    return vc
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView |> tableViewStyle
  }

  // MARK: Lifecycle

  override var inputAccessoryView: UIView? {
    return self.commentComposer
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.Replies()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
    self.tableView.registerCellClass(CommentViewMoreRepliesFailedCell.self)
    self.tableView.registerCellClass(RootCommentCell.self)
    self.tableView.registerCellClass(ViewMoreRepliesCell.self)
    self.tableView.tableFooterView = UIView()

    self.commentComposer.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureCommentComposerViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.commentComposer.configure(with: data)
      }

    self.viewModel.outputs.resetCommentComposer
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.commentComposer.resetInput()
      }

    self.viewModel.outputs.loadCommentIntoDataSource
      .observeForUI()
      .observeValues { [weak self] comment in
        self?.dataSource.loadRootComment(
          comment
        )

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.loadRepliesAndProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] repliesAndTotalCount, project in
        guard let self = self else { return }
        self.dataSource.load(repliesAndTotalCount: repliesAndTotalCount, project: project)
        self.tableView.reloadData()
        self.viewModel.inputs.dataSourceLoaded()
      }

    self.viewModel.outputs.loadFailableReplyIntoDataSource
      .observeForUI()
      .observeValues { [weak self] failableComment, replaceableCommentId, project in
        guard let self = self else { return }
        let (indexPath, newComment) = self.dataSource.replace(
          comment: failableComment,
          and: project,
          byCommentId: replaceableCommentId
        )
        guard let lastIndexPath = indexPath else { return }
        let (insert, scroll) = commentRepliesRowBehaviour(for: failableComment, newComment: newComment)
        let rowUpdate: Void = insert ?
          self.tableView.insertRows(at: [lastIndexPath], with: .fade) :
          self.tableView.reloadRows(at: [lastIndexPath], with: .fade)
        self.tableView.performBatchUpdates {
          rowUpdate
        } completion: { isComplete in
          if isComplete, scroll {
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
          }
        }
      }

    self.viewModel.outputs.showPaginationErrorState
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self = self else { return }
        self.dataSource.showPaginationErrorState()
        self.tableView.reloadData()
      }

    self.viewModel.outputs.scrollToReply
      .observeForUI()
      .observeValues { [weak self] replyId in
        if let indexPath = self?.dataSource.index(for: replyId) {
          self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
      }

    self.viewModel.outputs.userBlocked
      .observeForUI()
      .observeValues { [weak self] success in
        self?.commentComposer.isHidden = true

        // Scott TODO: Use localized strings once translations can be done [mbl-1037](https://kickstarter.atlassian.net/browse/MBL-1037)
        if success {
          self?.messageBannerViewController?
            .showBanner(with: .success, message: "This user has been successfully blocked")
        } else {
          self?.messageBannerViewController?
            .showBanner(with: .error, message: "Your request did not go through. Try again.")
        }
      }
  }

  private func presentBlockUserAlert(username: String) {
    let alert = UIAlertController
      .blockUserAlert(username: username, blockUserHandler: { _ in self.viewModel.inputs.blockUser() })
    self.present(alert, animated: true)
  }

  private func handleCommentCellHeaderTapped(in cell: UITableViewCell, _ author: Comment.Author) {
    guard AppEnvironment.current.currentUser != nil, featureBlockUsersEnabled() else { return }
    guard author.isBlocked == false else { return }

    let actionSheet = UIAlertController
      .blockUserActionSheet(
        blockUserHandler: { _ in self.presentBlockUserAlert(username: author.name) },
        sourceView: cell,
        isIPad: self.traitCollection.horizontalSizeClass == .regular
      )

    self.present(actionSheet, animated: true)
  }
}

// MARK: - UITableViewDelegate

extension CommentRepliesViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.dataSource.sectionForViewMoreReplies(indexPath) {
      // If there are no replies, retry the request for the first page.
      guard !self.dataSource.isRepliesSectionEmpty(in: tableView) else {
        self.viewModel.inputs.retryFirstPage()
        return
      }

      self.viewModel.inputs.paginateOrErrorCellWasTapped()
    } else if let comment = self.dataSource.comment(at: indexPath),
      self.dataSource.sectionForReplies(indexPath) {
      self.viewModel.inputs.didSelectComment(comment)
    }
  }

  override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
    (cell as? RootCommentCell)?.delegate = self
    (cell as? CommentCell)?.delegate = self
  }
}

// MARK: - CommentComposerViewDelegate

extension CommentRepliesViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText text: String) {
    self.viewModel.inputs.commentComposerDidSubmitText(text)
  }
}

// MARK: - CommentCellDelegate

extension CommentRepliesViewController: CommentCellDelegate {
  func commentCellDidTapHeader(_ cell: CommentCell, _ author: Comment.Author) {
    self.handleCommentCellHeaderTapped(in: cell, author)
  }

  func commentCellDidTapReply(_: CommentCell, comment _: Comment) {}

  func commentCellDidTapViewReplies(_: CommentCell, comment _: Comment) {}
}

// MARK: - RootCommentCellDelegate

extension CommentRepliesViewController: RootCommentCellDelegate {
  func commentCellDidTapHeader(_ cell: RootCommentCell, _ author: Comment.Author) {
    self.handleCommentCellHeaderTapped(in: cell, author)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.separatorStyle .~ .none
}

/**
 Returns `true` for insert and scrolling when  the `newComment`provided is `true`. Scrolling is false only if `comment`  status is `failed` and `newComment` is `false`.

 - parameter comment: `Comment` object that we need the `status` value from.
 - parameter newComment: `Bool` that we need to check if the comment is new to the table view.

 - returns: A  `Bool, Bool` which tells the caller to insert a table row and if the table view should scroll
 */
internal func commentRepliesRowBehaviour(for comment: Comment,
                                         newComment: Bool) -> (insert: Bool, scroll: Bool) {
  (insert: newComment, scroll: newComment || comment.status == .failed)
}
