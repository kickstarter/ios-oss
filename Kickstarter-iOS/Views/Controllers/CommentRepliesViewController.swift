import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

final class CommentRepliesViewController: UITableViewController {
  // MARK: Properties

  private let dataSource = CommentRepliesDataSource()
  private let viewModel: CommentRepliesViewModelType = CommentRepliesViewModel()

  // MARK: - Accessors

  internal static func configuredWith(comment: Comment) -> CommentRepliesViewController {
    let vc = CommentRepliesViewController.instantiate()
    vc.viewModel.inputs.configureWith(comment: comment)

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
    self.navigationItem.title = localizedString(key: "Replies", defaultValue: "Replies")

    self.tableView.dataSource = self.dataSource
    self.tableView.registerCellClass(RootCommentCell.self)
    self.tableView.tableFooterView = UIView()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCommentIntoDataSource
      .observeForUI()
      .observeValues { [weak self] comment in
        self?.dataSource.createContext(
          comment: comment
        )

        self?.tableView.reloadData()
      }
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
