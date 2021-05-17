import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CommentsViewController: UITableViewController {
  // MARK: - Properties

  fileprivate let dataSource = CommentsDataSource()
  fileprivate let viewModel: CommentsViewModelType = CommentsViewModel()

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    self.tableView.dataSource = self.dataSource

    self.dataSource.load()

    self.viewModel.inputs.viewDidLoad()

    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.estimatedRowHeight .~ 100.0
      |> \.separatorStyle .~ .none
  }

  // MARK: - View Model

  internal override func bindViewModel() {}

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
