import ObjectiveC
import UIKit
import Prelude
import Prelude_UIKit

extension UIViewController {
  open override class func initialize() {
    struct Static {
      static var token: Int = 0
    }

    // make sure this isn't a subclass
    guard self === UIViewController.self else { return }

    dispatch_once(&Static.token) {
      [
        (#selector(viewDidLoad), #selector(ksr_viewDidLoad)),
        (#selector(traitCollectionDidChange(_:)), #selector(ksr_traitCollectionDidChange(_:))),
        ].forEach { original, swizzled in

        let originalMethod = class_getInstanceMethod(self, original)
        let swizzledMethod = class_getInstanceMethod(self, swizzled)

        let didAddViewDidLoadMethod = class_addMethod(self,
          original,
          method_getImplementation(swizzledMethod),
          method_getTypeEncoding(swizzledMethod))

        if didAddViewDidLoadMethod {
          class_replaceMethod(self,
            swizzled,
            method_getImplementation(originalMethod),
            method_getTypeEncoding(originalMethod))
        } else {
          method_exchangeImplementations(originalMethod, swizzledMethod)
        }
      }
    }
  }

  internal func ksr_viewDidLoad(_ animated: Bool) {
    self.ksr_viewDidLoad(animated)
    self.bindViewModel()
  }

  /**
   The entry point to bind all view model outputs. Called just before `viewDidLoad`.
   */
  public func bindViewModel() {
  }

  /**
   The entry point to bind all styles to UI elements. Called just after `viewDidLoad`.
   */
  public func bindStyles() {
  }

  public func ksr_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }
}

extension UIViewController {
  public static var defaultNib: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }

  public static var storyboardIdentifier: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
}
