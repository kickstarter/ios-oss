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

  internal override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Internationalize
    self.navigationItem.title = localizedString(key: "Replies", defaultValue: "Replies")

    self.tableView.dataSource = self.dataSource
    self.tableView.registerCellClass(CommentCell.self)
    self.tableView.registerCellClass(RootCommentCell.self)
    self.tableView.registerCellClass(CommentRemovedCell.self)
    self.tableView.registerCellClass(CommentPostFailedCell.self)
    
    self.tableView.tableFooterView = UIView()

    self.commentComposer.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()
    
    self.viewModel.outputs.resetCommentComposer
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.commentComposer.resetInput()
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
      .observeValues { replies, project in
        self.dataSource.load(comments: replies, project: project)
        self.tableView.reloadData()
      }
    
    self.viewModel.outputs.loadFailableReplyIntoDataSource
      .observeForUI()
      .observeValues { failableComment, replaceableCommentId, project in
        self.dataSource.replace(comment: failableComment, and: project, byCommentId: replaceableCommentId)
        self.tableView.reloadData()
        // TODO: Scroll to bottom if not already doing so.
      }
    
    self.viewModel.outputs.configureCommentComposerViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.commentComposer.configure(with: data)
      }
  }
}

// MARK: - CommentComposerViewDelegate

extension CommentRepliesViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText text: String) {
    self.viewModel.inputs.commentComposerDidSubmitText(text)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.separatorStyle .~ .none
}
