import ObjectiveC
import UIKit

private var didSwizzle = false

extension UIActivityViewController {
  static func swizzle() {
    if didSwizzle {
      return
    }

    didSwizzle = true

    let klass = UIActivityViewController.self
    let originalSelector = NSSelectorFromString("_createMainPresenterIfNeeded")
    let swizzledSelector = #selector(dont_createMainPresenterIfNeeded)

    guard let originalMethod = class_getInstanceMethod(klass, originalSelector),
          let swizzledMethod = class_getInstanceMethod(klass, swizzledSelector)
    else {
      return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
  }

  @objc
  func dont_createMainPresenterIfNeeded() {
    print("Don't create the main presenter.")
  }
}
