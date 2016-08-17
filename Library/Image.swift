import UIKit

public func image(named name: String, inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
                        compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {

  return UIImage(named: name, inBundle: NSBundle(identifier: bundle.identifier),
                 compatibleWithTraitCollection: traitCollection)
}

public func image(named name: String,
                        tintColor: UIColor,
                        inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
                        compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {

  guard let img = image(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)
    else {
      return nil
  }

  UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
  defer { UIGraphicsEndImageContext() }

  tintColor.set()
  img.drawInRect(.init(origin: .zero, size: img.size))

  return UIGraphicsGetImageFromCurrentImageContext()
}
