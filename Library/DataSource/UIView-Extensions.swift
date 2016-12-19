import UIKit

extension UIView {
  open override class func initialize() {
    struct Static {
      static var token: Int = 0
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

  open override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  public func bindStyles() {
  }

  public func bindViewModel() {
  }

  public static var defaultReusableId: String {
    return self.description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")
  }

  internal func ksr_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }
}
