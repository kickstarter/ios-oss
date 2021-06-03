import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

final class CommentRepliesViewController: UITableViewController {
  
  // MARK: Properties
  private let viewModel: CommentRepliesViewModelType = CommentRepliesViewModel()
  private let dataSource = CommentRepliesDataSource()
  
  // MARK: - Accessors

  internal static func configuredWith(comment: Comment, project: Project) -> CommentRepliesViewController {
    let vc = CommentRepliesViewController.instantiate()
    vc.viewModel.inputs.configureWith(comment: comment, project: project)

    return vc
  }
  
  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView |> tableViewStyle
  }
  
  // MARK: Lifecycle
  
  internal override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Internationalize
    self.navigationItem.title = "Replies"

    self.tableView.dataSource = self.dataSource
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.tableFooterView = UIView()
    
    self.viewModel.inputs.viewDidLoad()
  }
  
  internal override func bindViewModel() {
    super.bindViewModel()
    
    self.viewModel.outputs.loadCommentAndProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] (comment, project) in
        self?.dataSource.load(
          comment: comment,
          project: project
        )
        
        self?.tableView.reloadData()
      }
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
