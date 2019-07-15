import Foundation
import UIKit

public protocol InstantiateProtocol: AnyObject {
  static func instantiate() -> Self
}

extension InstantiateProtocol where Self: UIViewController {
  public static func instantiate() -> Self {
    return Self(nibName: nil, bundle: nil)
  }
}

extension UIViewController: InstantiateProtocol {}
