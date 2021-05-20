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
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: Layout.Composer.originalHeight)
    let view = CommentComposerView(frame: frame)
    return view
  }()

  fileprivate let viewModel: CommentsViewModelType = CommentsViewModel()

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()

    self.viewModel.inputs.viewDidLoad()
  }

  override var inputAccessoryView: UIView? {
    return commentComposer
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
  }

  // MARK: - View Model

  internal override func bindViewModel() {}
}

extension CommentsViewController: CommentComposerViewDelegate {
  func commentComposerView(_: CommentComposerView, didSubmitText _: String) {
    // TODO: Capture submitted user comment in this delegate method.
  }
}
