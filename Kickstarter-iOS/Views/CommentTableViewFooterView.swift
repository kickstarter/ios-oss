import Library
import Prelude
import UIKit

final class CommentTableViewFooterView: UIView {
  // MARK: - Properties

  private let viewModel = CommentTableViewFooterViewModel()

  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.hidesWhenStopped .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    return indicator
  }()

  private var shouldShowActivityIndicator: Bool = false {
    didSet {
      shouldShowActivityIndicator
        ? activityIndicator.startAnimating()
        : activityIndicator.stopAnimating()
    }
  }

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configureWith(value: Bool) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = self |> \.autoresizingMask .~ .flexibleHeight
    _ = self |> \.backgroundColor .~ .ksr_white

    _ = (self.activityIndicator, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    self.viewModel.outputs.shouldStartLoaderIndicator
      .observeForUI()
      .observeValues { shouldLoad in
        self.shouldShowActivityIndicator = shouldLoad
      }
  }
}
