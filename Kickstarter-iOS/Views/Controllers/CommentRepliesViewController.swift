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

final class CommentRepliesViewController: UITableViewController {
  // MARK: Properties

  private let dataSource = CommentRepliesDataSource()
  private let viewModel: CommentRepliesViewModelType = CommentRepliesViewModel()

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  // MARK: - Accessors

  internal static func configuredWith(
    comment: Comment,
    project: Project,
    inputAreaBecomeFirstResponder: Bool
  ) -> CommentRepliesViewController {
    let vc = CommentRepliesViewController.instantiate()
    vc.viewModel.inputs.configureWith(
      comment: comment,
      project: project,
      inputAreaBecomeFirstResponder: inputAreaBecomeFirstResponder
    )

    return vc
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView |> tableViewStyle
  }

  // MARK: Lifecycle

  override var inputAccessoryView: UIView? {
    return self.commentComposer
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Internationalize
    self.navigationItem.title = localizedString(key: "Replies", defaultValue: "Replies")

    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(RootCommentCell.self)
    self.tableView.registerCellClass(ViewMoreRepliesCell.self)
    self.tableView.tableFooterView = UIView()

    self.commentComposer.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureCommentComposerViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.commentComposer.configure(with: data)
      }

    self.viewModel.outputs.loadCommentIntoDataSource
      .observeForUI()
      .observeValues { [weak self] comment in
        self?.dataSource.createContext(
          comment: comment
        )

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.loadRepliesAndProjectIntoDataSource
      .observeForUI()
      .observeValues { repliesAndTotalCount, project in
        self.dataSource.load(repliesAndTotalCount: repliesAndTotalCount, project: project)
        self.tableView.reloadData()
      }
  }
}

// MARK: - UITableViewDelegate

extension CommentRepliesViewController {
  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.dataSource.isCellInViewMoreRepliesSection(indexPath) {
      self.viewModel.inputs.viewMoreRepliesCellWasTapped()
    }
  }
}

// MARK: - CommentComposerViewDelegate

// TODO: Drive `resetInput()` from a ViewModel when we are implementing post comment for replies.
extension CommentRepliesViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText _: String) {
    self.commentComposer.resetInput()
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.separatorStyle .~ .none
}
