import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Composer {
    static let originalHeight: CGFloat = 80.0
  }

  enum ErrorState {
    static let cellHeightMuliplier: CGFloat = 0.70
  }
}

internal final class CommentsViewController: UITableViewController {
  // MARK: - Properties

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  private lazy var footerView: CommentTableViewFooterView = {
    CommentTableViewFooterView(frame: .zero)
      |> \.delegate .~ self
  }()

  private lazy var refreshIndicator: UIRefreshControl = {
    let refreshControl = UIRefreshControl()

    refreshControl.addTarget(
      self,
      action: #selector(self.refresh),
      for: .valueChanged
    )

    return refreshControl
  }()

  internal let viewModel: CommentsViewModelType = CommentsViewModel()
  private let dataSource = CommentsDataSource()

  // MARK: - Accessors

  internal static func configuredWith(project: Project? = nil,
                                      update: Update? = nil) -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: update)

    return vc
  }

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    self.commentComposer.delegate = self

    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
    self.tableView.registerCellClass(CommentsErrorCell.self)
    self.tableView.registerCellClass(EmptyCommentsCell.self)
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.refreshControl = self.refreshIndicator
    self.tableView.tableFooterView = UIView()
    self.tableView.keyboardDismissMode = .interactive

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override var inputAccessoryView: UIView? {
    return self.commentComposer
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> \.tableFooterView .~ self.footerView
      |> tableViewStyle
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.resetCommentComposerAndScrollToTop
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.commentComposer.resetInput()
        self?.tableView.scrollToTop()
      }

    self.viewModel.outputs.configureCommentComposerViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.commentComposer.configure(with: data)
      }

    self.viewModel.outputs.loadCommentsAndProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] comments, project, shouldShow in
        self?.dataSource.load(
          comments: comments,
          project: project,
          shouldShowErrorState: shouldShow
        )
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToRepliesWithCommentProjectUpdateAndBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] comment, project, update, becomeFirstResponder in
        let vc = CommentRepliesViewController.configuredWith(
          comment: comment,
          project: project,
          update: update,
          inputAreaBecomeFirstResponder: becomeFirstResponder,
          replyId: nil
        )
        self?.navigationController?.pushViewController(vc, animated: true)
      }

    self.viewModel.outputs.beginOrEndRefreshing
      .observeForUI()
      .observeValues { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
      }

    self.viewModel.outputs.configureFooterViewWithState
      .observeForUI()
      .observeValues { [weak self] state in
        self?.footerView.configureWith(value: state)

        // Force tableFooterView to layout
        DispatchQueue.main.async {
          self?.tableView.tableFooterView = nil
          self?.tableView.tableFooterView = self?.footerView
          self?.tableView.layoutIfNeeded()
        }
      }

    self.viewModel.outputs.cellSeparatorHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.tableView.separatorStyle = isHidden ? .none : .singleLine
      }

    self.viewModel.outputs.showHelpWebViewController
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.presentHelpWebViewController(with: helpType)
      }
  }

  // MARK: - Actions

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

// MARK: - UITableViewDelegate

extension CommentsViewController {
  override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    (cell as? CommentCell)?.delegate = self
    (cell as? CommentRemovedCell)?.delegate = self

    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let comment = self.dataSource.comment(at: indexPath) else { return }

    self.viewModel.inputs.didSelectComment(comment)
  }
}

// MARK: - CommentComposerViewDelegate

extension CommentsViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText text: String) {
    self.viewModel.inputs.commentComposerDidSubmitText(text)
  }
}

// MARK: - CommentTableViewFooterViewDelegate

extension CommentsViewController: CommentTableViewFooterViewDelegate {
  func commentTableViewFooterViewDidTapRetry(_: CommentTableViewFooterView) {
    self.viewModel.inputs.commentTableViewFooterViewDidTapRetry()
  }
}

// MARK: - UITableViewDelegate

extension CommentsViewController {
  override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.dataSource.isInErrorState(indexPath: indexPath) {
      return (self.view.safeAreaLayoutGuide.layoutFrame.height * Layout.ErrorState.cellHeightMuliplier)
    }

    return UITableView.automaticDimension
  }
}

// MARK: - CommentCellDelegate

extension CommentsViewController: CommentCellDelegate {
  func commentCellDidTapReply(_: CommentCell, comment: Comment) {
    self.viewModel.inputs.commentCellDidTapReply(comment: comment)
  }

  func commentCellDidTapViewReplies(_: CommentCell, comment: Comment) {
    self.viewModel.inputs.commentCellDidTapViewReplies(comment)
  }
}

// MARK: - CommentRemovedCellDelegate

extension CommentsViewController: CommentRemovedCellDelegate {
  func commentRemovedCell(_: CommentRemovedCell, didTapURL: URL) {
    self.viewModel.inputs.commentRemovedCellDidTapURL(didTapURL)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.separatorColor .~ UIColor.ksr_support_200
    |> \.separatorInset .~ .zero
}

internal func commentsViewController(
  for project: Project? = nil,
  update: Update? = nil
) -> UIViewController {
  return CommentsViewController.configuredWith(project: project, update: update)
}
