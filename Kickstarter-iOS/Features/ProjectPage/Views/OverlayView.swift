import Foundation
import Library
import Prelude
import UIKit

protocol OverlayViewPresenting {
  var overlayView: OverlayView? { get set }
  var windowTransform: CGAffineTransform? { get }

  func hideOverlayView()
  func locationInView(_ gestureRecognizer: UIGestureRecognizer) -> CGPoint
  func showOverlayView(with subview: UIView)
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
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> overlayViewStyle
  }
}

// MARK: - Styles

private let overlayViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ UIColor.ksr_black.withAlphaComponent(OverlayViewLayout.Alpha.max)
}

extension OverlayViewPresenting where Self: UIViewController {
  var windowTransform: CGAffineTransform? {
    UIApplication.shared.windows.first?.transform
  }

  func showOverlayView(with subview: UIView) {
    self.overlayView?.removeFromSuperview()

    guard let window = UIApplication.shared.windows.first,
      let overlayView = self.overlayView else {
      return
    }

    _ = (subview, overlayView)
      |> ksr_addSubviewToParent()

    _ = (overlayView, window)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    if AppEnvironment.current.isVoiceOverRunning() {
      UIAccessibility.post(
        notification: UIAccessibility.Notification.layoutChanged,
        argument: overlayView
      )
    }
  }

  func hideOverlayView() {
    self.overlayView?.subviews.forEach { $0.removeFromSuperview() }
    self.overlayView?.removeFromSuperview()
  }

  func locationInView(_ gestureRecognizer: UIGestureRecognizer) -> CGPoint {
    gestureRecognizer.location(in: self.overlayView)
  }

  func updateOverlayView(with alpha: CGFloat) {
    self.overlayView?.backgroundColor = .ksr_black.withAlphaComponent(alpha)
  }

  func transformSubviews(with transform: CGAffineTransform) {
    self.overlayView?.subviews.forEach { view in
      view.transform = transform
    }
  }
}
