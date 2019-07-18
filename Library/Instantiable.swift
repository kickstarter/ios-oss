import Foundation
import UIKit

public protocol Instantiable: AnyObject {
  static func instantiate() -> Self
}

extension Instantiable where Self: UIViewController {
  public static func instantiate() -> Self {
    return Self(nibName: nil, bundle: nil)
  }
}

extension UIViewController: Instantiable {}
