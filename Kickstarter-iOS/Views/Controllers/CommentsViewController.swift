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
}

internal final class CommentsViewController: UITableViewController {
  // MARK: - Properties

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()
  
  private lazy var footerView = { CommentTableViewFooter() }()

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

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.project_menu_buttons_comments()
    self.commentComposer.configure(with: (nil, true))
    self.commentComposer.delegate = self
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.refreshControl = self.refreshIndicator
    self.tableView.tableFooterView = UIView()

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

  // MARK: - Views

  private func configureViews() {
    self.commentComposer.delegate = self
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.estimatedRowHeight .~ 100.0
      |> \.separatorInset .~ .zero
      |> \.separatorColor .~ UIColor.ksr_support_200
      //|> \.tableFooterView .~ footerView
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.commentComposer.rac.hidden = self.viewModel.outputs.isCommentComposerHidden

    self.viewModel.outputs.loadCommentsAndProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] comments, project in
        self?.dataSource.load(
          comments: comments,
          project: project
        )
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.configureCommentComposerViewWithData
      .observeForUI()
      .observeValues { [weak self] avatarUrl, isBacking in
        self?.commentComposer.configure(with: (avatarUrl, isBacking))
      }

    self.viewModel.outputs.goToCommentReplies
      .observeForControllerAction()
      .observeValues { [weak self] _, _ in
        let vc = CommentRepliesViewController.instantiate()
        self?.navigationController?.pushViewController(vc, animated: true)
      }

    self.viewModel.outputs.isCommentsLoading
      .observeForUI()
      .observeValues { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
      }
    
    self.viewModel.outputs.shouldShowLoadMoreIndicator
      .observeForUI()
      .observeValues  { [weak self] shouldHide in
        self?.footerView.shouldAnimateLoadMoreIndicator = shouldHide
      }
  }

  // MARK: - Actions

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

// MARK: - CommentsViewController Delegate

extension CommentsViewController {
  override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
//    self.tableView.addLoading(indexPath) {
//      self.viewModel.inputs.willDisplayRow(
//        self.dataSource.itemIndexAt(indexPath),
//        outOf: self.dataSource.numberOfItems()
//      )
//        // add your code here
//        // append Your array and reload your tableview
//      self.tableView.stopLoading() // stop your indicator
//      }

    // TODO: Call this method after post comment is successful to clear the input field text
    // self.commentComposer.clearOnSuccess()
  }
}

// MARK: - CommentComposerViewDelegate

extension CommentsViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText _: String) {
    // TODO: Capture submitted user comment in this delegate method.
  }
}

// MARK: - UITableViewDelegate

extension CommentsViewController {
  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let comment = self.dataSource.comment(at: indexPath) else { return }

    self.viewModel.inputs.didSelectComment(comment)
  }
}


private extension UITableView {

  func indicatorView() -> UIActivityIndicatorView{
      var activityIndicatorView = UIActivityIndicatorView()
      if self.tableFooterView == nil {
          let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 80)
          activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
          activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
          activityIndicatorView.hidesWhenStopped = true

          self.tableFooterView = activityIndicatorView
          return activityIndicatorView
      }
      else {
          return activityIndicatorView
      }
  }

  func addLoading(_ indexPath:IndexPath, closure: @escaping (() -> Void)){
      indicatorView().startAnimating()
      if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
          if indexPath == lastVisibleIndexPath && indexPath.row == self.numberOfRows(inSection: 0) - 1 {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  closure()
              }
          }
      }
  }

  func stopLoading() {
      if self.tableFooterView != nil {
          self.indicatorView().stopAnimating()
          self.tableFooterView = nil
      }
      else {
          self.tableFooterView = nil
      }
  }
}
