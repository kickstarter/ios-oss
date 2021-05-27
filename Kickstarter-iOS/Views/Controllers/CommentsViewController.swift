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

    self.configureViews()

    self.navigationItem.title = Strings.project_menu_buttons_comments()

    self.tableView.dataSource = self.dataSource
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)

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
    // TODO: Use actual data from CommentViewModel to configure composer.
    self.commentComposer.configure(with: (nil, true))
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
  }

  // MARK: - View Model

  internal override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outputs.dataSource
      .observeForUI()
      .observeValues { [weak self] comments, _, project in
        self?.dataSource.load(
          comments: comments,
          project: project
        )
        self?.tableView.reloadData()
      }
    // TODO: Call this method after post comment is successful to clear the input field text
    // self.commentComposer.clearOnSuccess()
  }
}

extension CommentsViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText _: String) {
    // TODO: Capture submitted user comment in this delegate method.
  }
}
