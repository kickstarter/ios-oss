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
  
  // MARK: - Configuration
  internal static func configuredWith(project: Project? = nil, update: Update? = nil)
    -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: update)
    
    return vc
  }
  
  // MARK: - Lifecycle
  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.loadCommentsIntoDataSource
      .observeForUI()
      .logEvents()
      .observeValues { comments in
        self.dataSource.updateCommentsSection(comments: comments)
        self.tableView.reloadData()
      }
  }
  
}

// MARK: - Tableview Delegates
extension CommentsViewController {
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }
}
