import UIKit

public func image(
  named name: String,
  inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil
) -> UIImage? {
  return UIImage(named: name, in: Bundle(identifier: bundle.identifier), compatibleWith: traitCollection)
}

public func image(
  named name: String,
  tintColor: UIColor,
  inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil
) -> UIImage? {
  guard let img = image(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)
  else {
    return nil
  }

  UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
  defer { UIGraphicsEndImageContext() }

  tintColor.set()
  img.draw(in: .init(origin: .zero, size: img.size))

  return UIGraphicsGetImageFromCurrentImageContext()
}

public func image(
  named name: String,
  inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil,
  alpha: CGFloat = 1.0
) -> UIImage? {
  return image(
    named: name,
    inBundle: bundle,
    compatibleWithTraitCollection: traitCollection
  )?.alpha(alpha)
}

extension UIImage {
  fileprivate func alpha(_ value: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(at: CGPoint.zero, blendMode: .normal, alpha: value)

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  public func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
    // Determine the scale factor that preserves aspect ratio
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height

    let scaleFactor = min(widthRatio, heightRatio)

    // Compute the new image size that preserves aspect ratio
    let scaledImageSize = CGSize(
      width: size.width * scaleFactor,
      height: size.height * scaleFactor
    )

    // Draw and return the resized UIImage
    let renderer = UIGraphicsImageRenderer(
      size: scaledImageSize
    )

    let scaledImage = renderer.image { _ in
      self.draw(in: CGRect(
        origin: .zero,
        size: scaledImageSize
      ))
    }

    return scaledImage
  }
}
