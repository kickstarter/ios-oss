import UIKit

public final class KSRButton: UIButton {
  private lazy var activityIndicator = { UIActivityIndicatorView(style: .medium) }()

  private var style: KSRButtonStyle = .filled
  private var isLoading = false

  // MARK: - Lifecycle

  public init(style: KSRButtonStyle) {
    super.init(frame: .zero)
    self.style = style
    self.setupButton()
    self.setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupButton() {
    self.applyStyleConfiguration(self.style)

    self.activityIndicator.hidesWhenStopped = true
    self.activityIndicator.color = self.style.loadingIndicatorColor.mixDarker(0.35)
    self.addSubview(self.activityIndicator)

    self.setNeedsUpdateConfiguration()
  }

  private func setupConstraints() {
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
  }

  public func starLoading() {
    self.activityIndicator.startAnimating()
    self.isEnabled = false
    self.setNeedsUpdateConfiguration()
  }

  public func stopLoading() {
    self.activityIndicator.stopAnimating()
    self.isEnabled = true
    self.setNeedsUpdateConfiguration()
  }
}
