import UIKit

/**
 *  A type that behaves like a UIScreen.
 */
public protocol UIScreenType {
  var bounds: CGRect { get }
}

extension UIScreen: UIScreenType {
}

internal struct MockScreen: UIScreenType {
  internal let bounds = CGRect(x: -1.0, y: -2.0, width: -3.0, height: -4.0)
}
