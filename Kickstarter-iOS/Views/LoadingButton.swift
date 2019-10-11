import Prelude
import UIKit

final class LoadingButton: UIButton {
  // MARK: - Properties

  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .white)
      |> \.hidesWhenStopped .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public var isLoading: Bool = false {
    didSet {
      if self.isLoading == oldValue { return }

      if self.isLoading {
        self.startLoading()
      } else {
        self.stopLoading()
      }

      _ = self
        |> \.isUserInteractionEnabled .~ !self.isLoading
    }
  }

  private var originalTitle: String?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(self.activityIndicator)
    self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func setTitle(_ title: String?, for state: UIControl.State) {
    // Only allow setting new title if the button is not in a loading state
    guard !self.isLoading else { return }

    super.setTitle(title, for: state)
  }

  // MARK: - Titles

  private func removeTitle() {
    _ = self
      |> \.originalTitle .~ self.title(for: .normal)

    _ = self.titleLabel
      ?|> \.text .~ nil
  }

  private func restoreTitle() {
    _ = self.titleLabel
      ?|> \.text .~ self.originalTitle

    _ = self
      |> \.originalTitle .~ nil
  }

  // MARK: - Loading

  private func startLoading() {
    self.removeTitle()
    self.activityIndicator.startAnimating()
  }

  private func stopLoading() {
    self.activityIndicator.stopAnimating()
    self.restoreTitle()
  }
}
