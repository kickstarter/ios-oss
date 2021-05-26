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

  // MARK: - Configuration

  internal static func configuredWith(project: Project)
    -> CommentsViewController {
    let vc = CommentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)

    self.viewModel.inputs.viewDidLoad()
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
      |> \.separatorInset .~ .zero
      |> \.separatorColor .~ UIColor.ksr_support_200
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.dataSource
      .observeForUI()
      .observeValues { [weak self] comments, user, project in
        self?.dataSource.load(
          comments: comments,
          loggedInUser: user,
          project: project
        )
        self?.tableView.reloadData()
      }
  }
}
