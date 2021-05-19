import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CommentsViewController: UITableViewController {
  // MARK: - Properties

  private let viewModel: CommentsViewModelType = CommentsViewModel()
  private let dataSource = CommentsDataSource()
  private let refreshIndicator = UIRefreshControl()

  // MARK: - Configuration

  internal static func configuredWith(project: Project? = nil, update: Update? = nil) -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: update)

    return vc
  }

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupTableView()
    self.setupRefreshControl()
    
    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()
    // TODO: Fill this out with comment card, comment composer.
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.loadCommentsIntoDataSource
      .observeForUI()
      .observeValues { comments in
        self.dataSource.updateCommentsSection(comments: comments)
        self.tableView.reloadData()
      }
    
    self.viewModel.outputs.commentsAreLoading
      .observeForUI()
      .observeValues { [weak self] in
        $0 ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
      }
  }
  
  // MARK: Helpers
  private func setupTableView() {
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.refreshControl = refreshIndicator
  }
  
  private func setupRefreshControl() {
    refreshIndicator.addTarget(self,
                               action: #selector(self.refresh),
                               for: .valueChanged)
  }
  
  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

// MARK: - Tableview Delegates

extension CommentsViewController {
  override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }
}
