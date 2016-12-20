import ObjectiveC
import UIKit
import Prelude
import Prelude_UIKit

private func swizzle(_ vc: UIViewController.Type) {

  [
    (#selector(vc.viewDidLoad), #selector(vc.ksr_viewDidLoad)),
    (#selector(vc.traitCollectionDidChange(_:)), #selector(vc.ksr_traitCollectionDidChange(_:))),
    ].forEach { original, swizzled in

      let originalMethod = class_getInstanceMethod(vc, original)
      let swizzledMethod = class_getInstanceMethod(vc, swizzled)

      let didAddViewDidLoadMethod = class_addMethod(vc,
                                                    original,
                                                    method_getImplementation(swizzledMethod),
                                                    method_getTypeEncoding(swizzledMethod))

      if didAddViewDidLoadMethod {
        class_replaceMethod(vc,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
      }
  }
}

extension UIViewController {
  open override class func initialize() {
    struct Static {
      static var token: Int = 0
    }

    // make sure this isn't a subclass
    guard self === UIViewController.self else { return }

    swizzle(self)
  }

  internal func ksr_viewDidLoad() {
    self.ksr_viewDidLoad()
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
