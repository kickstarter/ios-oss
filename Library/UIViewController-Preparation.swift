import ObjectiveC
import UIKit
import Prelude
import Prelude_UIKit

extension UIViewController {
  public override class func initialize() {
    struct Static {
      static var token: dispatch_once_t = 0
    }

    // make sure this isn't a subclass
    guard self === UIViewController.self else { return }

    dispatch_once(&Static.token) {
      let originalSelector = #selector(viewDidLoad)
      let swizzledSelector = #selector(ksr_viewDidLoad)

      let originalMethod = class_getInstanceMethod(self, originalSelector)
      let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

      let didAddMethod = class_addMethod(self,
                                         originalSelector,
                                         method_getImplementation(swizzledMethod),
                                         method_getTypeEncoding(swizzledMethod))

      if didAddMethod {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
      }
    }
  }

  internal func ksr_viewDidLoad(animated: Bool) {
    self.ksr_viewDidLoad(animated)
    self.bindViewModel()
    self.bindStyles()
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
}

extension UIViewController {
  public static var defaultNib: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
