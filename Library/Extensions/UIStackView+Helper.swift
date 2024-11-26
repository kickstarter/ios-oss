import UIKit

extension UIStackView {
  /// Adds multiple views to the stack view as arranged subviews.
  ///
  /// - Parameter subviews: An array of `UIView` objects to be added as arranged subviews.
  /// - Note: This method iterates through the provided views and calls `addArrangedSubview(_:)`
  ///         on each, adding them to the stack view in the order they appear in the array.
  public func addArrangedSubviews(_ subviews: [UIView]) {
    subviews.forEach(self.addArrangedSubview)
  }
}
