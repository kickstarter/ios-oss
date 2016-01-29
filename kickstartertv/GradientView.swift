import UIKit

class GradientView: UIView {

  override class func layerClass() -> AnyClass {
    return CAGradientLayer.self
  }

  var gradientLayer: CAGradientLayer? {
    return self.layer as? CAGradientLayer
  }

  @IBInspectable var startPoint: CGPoint {
    get {
      return self.gradientLayer?.startPoint ?? CGPointZero
    }
    set {
      self.gradientLayer?.startPoint = newValue
    }
  }

  @IBInspectable var endPoint: CGPoint {
    get {
      return self.gradientLayer?.endPoint ?? CGPointZero
    }
    set {
      self.gradientLayer?.endPoint = newValue
    }
  }

  @IBInspectable var startColor: UIColor?
  @IBInspectable var endColor: UIColor?


  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = UIColor.clearColor()

    setGradient([(startColor, 0.0), (endColor, 1.0)])
  }

  func setGradient(points: [(color: UIColor?, location: Float)]) -> Void {
    self.gradientLayer?.colors = points.map { point in
      point.color?.CGColor ?? UIColor.clearColor().CGColor
    }

    self.gradientLayer?.locations = points.map { point in
      NSNumber(float: point.location)
    }
  }
}
