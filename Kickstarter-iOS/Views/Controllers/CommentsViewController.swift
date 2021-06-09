import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Composer {
    static let originalHeight: CGFloat = 80.0
  }

  enum Footer {
    static let height: CGFloat = 80.0
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

  private let viewModel: CommentsViewModelType = CommentsViewModel()
  private let dataSource = CommentsDataSource()

  // MARK: - Accessors

  internal static func configuredWith(project: Project? = nil) -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: nil)

    return vc
  }

  // MARK: - Accessors

  internal static func configuredWith(project: Project) -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: nil)

    return vc
  }

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    self.commentComposer.delegate = self

    self.tableView.dataSource = self.dataSource
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
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

    self.commentComposer.rac.hidden = self.viewModel.outputs.commentComposerViewHidden

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
      .observeValues { [weak self] comments, project in
        self?.dataSource.load(
          comments: comments,
          project: project
        )
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToCommentReplies
      .observeForControllerAction()
      .observeValues { [weak self] _, _ in
        let vc = CommentRepliesViewController.instantiate()
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
  }

  // MARK: - Actions

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

// MARK: - UITableViewDelegate

extension CommentsViewController {
  override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
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

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.estimatedRowHeight .~ 100.0
    |> \.separatorInset .~ .zero
    |> \.separatorColor .~ UIColor.ksr_support_200
}
