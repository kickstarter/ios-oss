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

final class CommentRepliesViewController: UITableViewController {
  // MARK: Properties

  private let dataSource = CommentRepliesDataSource()
  internal let viewModel: CommentRepliesViewModelType = CommentRepliesViewModel()

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  // MARK: - Accessors

  internal static func configuredWith(
    comment: Comment,
    project: Project,
    inputAreaBecomeFirstResponder: Bool
  ) -> CommentRepliesViewController {
    let vc = CommentRepliesViewController.instantiate()
    vc.viewModel.inputs.configureWith(
      comment: comment,
      project: project,
      inputAreaBecomeFirstResponder: inputAreaBecomeFirstResponder
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

    // TODO: Internationalize
    self.navigationItem.title = localizedString(key: "Replies", defaultValue: "Replies")

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
  }
}

// MARK: - UITableViewDelegate

extension CommentRepliesViewController {
  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.dataSource.sectionForViewMoreReplies(indexPath) {
      self.viewModel.inputs.paginateOrErrorCellWasTapped()
    } else if let comment = self.dataSource.comment(at: indexPath),
      self.dataSource.sectionForReplies(indexPath) {
      self.viewModel.inputs.didSelectComment(comment)
    }
  }
}

// MARK: - CommentComposerViewDelegate

extension CommentRepliesViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText text: String) {
    self.viewModel.inputs.commentComposerDidSubmitText(text)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.separatorStyle .~ .none
}

internal func commentRepliesRowBehaviour(for comment: Comment,
                                         newComment: Bool) -> (insert: Bool, scroll: Bool) {
  (insert: newComment, scroll: newComment || comment.status == .failed)
}
