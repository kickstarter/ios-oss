import Library
import Prelude
import UIKit

final class CommentTableViewFooter: UIView {
  // MARK: - Properties

  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    indicator.startAnimating()
    return indicator
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindViewModel()
    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureViews() {
    _ = self |> \.autoresizingMask .~ .flexibleHeight
    _ = self |> \.backgroundColor .~ .ksr_white

    _ = (self.activityIndicator, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()
  }
}
