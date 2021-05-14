import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CommentsViewController: UITableViewController {
  // MARK: - Properties

  private lazy var commentComposer: CommentComposerView = {
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  fileprivate let viewModel: CommentsViewModelType = CommentsViewModel()

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    tableView.keyboardDismissMode = .interactive
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")

    self.viewModel.inputs.viewDidLoad()
  }

  override var inputAccessoryView: UIView? {
    return commentComposer
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()
  }

  // MARK: - View Model

  internal override func bindViewModel() {}
}

extension CommentsViewController {
  // MARK: - UITableViewDataSource & UITableViewDelegate

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return 25
  }

  override func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") else { fatalError() }
    cell.textLabel?
      .text = "Seen on reddit, this promises to be a great game with beautiful pixdel arts, love it!"
    cell.textLabel?.numberOfLines = 0
    return cell
  }
}
