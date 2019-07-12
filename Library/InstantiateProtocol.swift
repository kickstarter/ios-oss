import Foundation
import UIKit

public protocol InstantiateProtocol: class {
  associatedtype ViewController

  static func instantiate() -> ViewController
}

extension InstantiateProtocol where Self: UIViewController {
  public static func instantiate() -> Self {
    return Self.init(nibName: nil, bundle: nil)
  }
}

extension UIViewController: InstantiateProtocol {}
