import UIKit

public func image(named name: String, inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
                        compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {

  return UIImage(named: name, inBundle: NSBundle(identifier: bundle.identifier),
                 compatibleWithTraitCollection: traitCollection)
}
