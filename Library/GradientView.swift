import Foundation
import UIKit

@IBDesignable
public final class GradientView: UIView {

  public override class func layerClass() -> AnyClass {
    return CAGradientLayer.self
  }

  public var gradientLayer: CAGradientLayer? {
    return self.layer as? CAGradientLayer
  }

  @IBInspectable
  public var startPoint: CGPoint {
    get {
      return self.gradientLayer?.startPoint ?? .zero
    }
    set {
      self.gradientLayer?.startPoint = newValue
    }
  }

  @IBInspectable
  public var endPoint: CGPoint {
    get {
      return self.gradientLayer?.endPoint ?? .zero
    }
    set {
      self.gradientLayer?.endPoint = newValue
    }
  }

  @IBInspectable public var startColor: UIColor?
  @IBInspectable public var endColor: UIColor?

  public override func awakeFromNib() {
    super.awakeFromNib()
    setGradient([(startColor, 0.0), (endColor, 1.0)])
  }

  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setGradient([(startColor, 0.0), (endColor, 1.0)])
  }

  public func setGradient(points: [(color: UIColor?, location: Float)]) -> Void {
    backgroundColor = UIColor.clearColor()

    self.gradientLayer?.colors = points.map { point in
      point.color?.CGColor ?? UIColor.clearColor().CGColor
    }

    self.gradientLayer?.locations = points.map { point in
      NSNumber(float: point.location)
    }
  }
}
