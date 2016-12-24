import UIKit

private func swizzle(_ v: UIView.Type) {

  [(#selector(v.traitCollectionDidChange(_:)), #selector(v.ksr_traitCollectionDidChange(_:)))]
    .forEach { original, swizzled in

      let originalMethod = class_getInstanceMethod(v, original)
      let swizzledMethod = class_getInstanceMethod(v, swizzled)

      let didAddViewDidLoadMethod = class_addMethod(v,
                                                    original,
                                                    method_getImplementation(swizzledMethod),
                                                    method_getTypeEncoding(swizzledMethod))

      if didAddViewDidLoadMethod {
        class_replaceMethod(v,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
      }
  }
}

extension UIView {
  open override class func initialize() {
    // make sure this isn't a subclass
    guard self === UIView.self else { return }

    swizzle(self)
  }

  open override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  open func bindStyles() {
  }

  open func bindViewModel() {
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
