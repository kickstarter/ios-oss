import Foundation
import Library
import Prelude
import UIKit

protocol OverlayViewPresenting {
  var overlayView: OverlayView? { get set }
  var windowTransform: CGAffineTransform? { get }

  func hideOverlayView()
  func locationInView(_ gestureRecognizer: UIGestureRecognizer) -> CGPoint
  func showOverlayView(with subviews: [UIView])
  func updateOverlayView(with alpha: CGFloat)
  func transformSubviews(with transform: CGAffineTransform)
}

internal enum OverlayViewLayout {
  enum Alpha {
    static let min: CGFloat = 0.4
    static let max: CGFloat = 0.8
  }
}

final class OverlayView: UIView {
  fileprivate lazy var stackView = { UIStackView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> overlayViewStyle

    _ = self.stackView
      |> stackViewStyle
  }

  // MARK: Helpers

  private func configureSubviews() {
    _ = (self.stackView, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.stackView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.stackView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor)
    ])
  }
}

// MARK: - Styles

private let overlayViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ UIColor.ksr_support_700.withAlphaComponent(OverlayViewLayout.Alpha.max)
}

private let stackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.alignment .~ .center
    |> \.distribution .~ .fill
}

extension OverlayViewPresenting where Self: UIViewController {
  var windowTransform: CGAffineTransform? {
    UIApplication.shared.windows.first?.transform
  }

  func showOverlayView(with subviews: [UIView]) {
    self.overlayView?.removeFromSuperview()

    guard let window = UIApplication.shared.windows.first,
      let overlayView = self.overlayView else {
      return
    }

    _ = (subviews, overlayView.stackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (overlayView, window)
      |> ksr_addSubviewToParent()

    if AppEnvironment.current.isVoiceOverRunning() {
      UIAccessibility.post(
        notification: UIAccessibility.Notification.layoutChanged,
        argument: overlayView
      )
    }
  }

  func hideOverlayView() {
    self.overlayView?.removeFromSuperview()
  }

  func locationInView(_ gestureRecgonizer: UIGestureRecognizer) -> CGPoint {
    gestureRecgonizer.location(in: self.overlayView)
  }

  func updateOverlayView(with alpha: CGFloat) {
    self.overlayView?.alpha = alpha
  }

  func transformSubviews(with transform: CGAffineTransform) {
    self.overlayView?.stackView.arrangedSubviews.forEach { view in
      view.transform = transform
    }
  }
}
