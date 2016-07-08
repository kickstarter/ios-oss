import UIKit

extension UIView {
  public override class func initialize() {
    struct Static {
      static var token: dispatch_once_t = 0
    }

    // make sure this isn't a subclass
    guard self === UIView.self else { return }

    dispatch_once(&Static.token) {
      [
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

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  public func bindStyles() {
  }

  public func bindViewModel() {
  }

  public static var defaultReusableId: String {
    return self.description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")
  }

  internal func ksr_traitCollectionDidChange(previousTraitCollection: UITraitCollection) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }
}
