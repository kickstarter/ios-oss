import Foundation
import Library
import ObjectiveC
import UIKit

private enum ShimmerConstants {
  enum Locations {
    static let start: [NSNumber] = [-1.0, -0.5, 0.0]
    static let end: [NSNumber] = [1.0, 1.5, 2.0]
  }

  enum Animation {
    static let movingAnimationDuration: CFTimeInterval = 1.25
    static let delayBetweenAnimationLoops: CFTimeInterval = 0.3
  }
}

private struct AssociatedKeys {
  static var shimmerLayers = "shimmerLayers"
}

protocol ShimmerLoading: AnyObject {
  func shimmerViews() -> [UIView]
  func startLoading()
  func stopLoading()
}

extension ShimmerLoading where Self: UIView {
  private var shimmerLayers: [CAGradientLayer] {
    get {
      guard
        let value = objc_getAssociatedObject(self, &AssociatedKeys.shimmerLayers) as? [CAGradientLayer]
      else { return [] }

      return value
    }
    set(newValue) {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.shimmerLayers,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  // MARK: - Accessors

  func startLoading() {
    self.shimmerViews()
      .forEach { view in
        let gradientLayer = shimmerGradientLayer(with: view.bounds)
        let animation = shimmerAnimation()
        let animationGroup = shimmerAnimationGroup(with: animation)

        gradientLayer.add(animationGroup, forKey: animation.keyPath)

        view.layer.addSublayer(gradientLayer)
        self.shimmerLayers.append(gradientLayer)
      }
  }

  func stopLoading() {
    self.shimmerLayers.forEach { $0.removeFromSuperlayer() }
  }

  func layoutGradientLayers() {
    self.layoutIfNeeded()

    self.shimmerLayers.forEach { layer in
      layer.frame = layer.superlayer?.bounds ?? .zero
      layer.setNeedsLayout()
    }
  }
}

private func shimmerGradientLayer(with frame: CGRect) -> CAGradientLayer {
  let gradientBackgroundColor: CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
  let gradientMovingColor: CGColor = UIColor(white: 0.75, alpha: 1.0).cgColor

  let gradientLayer = CAGradientLayer()
  gradientLayer.frame = frame
  gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
  gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

  gradientLayer.colors = [
    gradientBackgroundColor,
    gradientMovingColor,
    gradientBackgroundColor
  ]

  gradientLayer.locations = ShimmerConstants.Locations.start

  return gradientLayer
}

private func shimmerAnimation() -> CABasicAnimation {
  let locationsKeyPath = \CAGradientLayer.locations

  let animation = CABasicAnimation(keyPath: locationsKeyPath._kvcKeyPathString)
  animation.fromValue = ShimmerConstants.Locations.start
  animation.toValue = ShimmerConstants.Locations.end
  animation.duration = ShimmerConstants.Animation.movingAnimationDuration
  animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

  return animation
}

private func shimmerAnimationGroup(with animation: CABasicAnimation) -> CAAnimationGroup {
  let animationGroup = CAAnimationGroup()

  animationGroup.duration = ShimmerConstants.Animation.movingAnimationDuration
    + ShimmerConstants.Animation.delayBetweenAnimationLoops
  animationGroup.animations = [animation]
  animationGroup.repeatCount = .infinity
  animationGroup.beginTime = CACurrentMediaTime()

  return animationGroup
}
